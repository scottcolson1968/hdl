// -----------------------------------------------------------------------------
// tx_csum_open - open autonomous TX TCP checksum offload (FIFO-straddle design)
//
// The proven packet-mode eth_tx_fifo does all store-and-forward buffering; this
// module only TAPS the streams on each side of it (combinational AXIS pass-
// throughs, no data buffering here). Jumbo-capable because the FIFO is.
//
//   mcdma M_AXIS_MM2S -> s_in  -> [accumulate csum] -> m_fifo -> eth_tx_fifo/S_AXIS
//   eth_tx_fifo/M_AXIS -> s_fifo -> [patch csum byte] -> m_out -> xxv/axis_tx_0
//
// INPUT side: watches accepted beats, parses Eth/IPv4/TCP (parse completes at
// input beat 4 = the beat carrying bytes 32..39, which includes dst-IP-low and
// the first TCP bytes at offset 34), accumulates the ones-complement sum of the
// 16b BE words over the TCP segment [tcp_start .. 14+ip_totlen) with the csum
// field zeroed, seeded with the pseudo-header. At the frame's tlast it folds +
// complements and pushes {chk,insert_beat,lane,en} into a small meta FIFO.
//
// OUTPUT side: counts beats of each drained frame; on the beat holding the csum
// field it muxes in the meta-head chk (network order); pops meta at tlast. Non-
// TCP/non-IPv4/VLAN frames carry en=0 and pass through unchanged.
//
// Data/handshake pass straight through both sides (the FIFO owns backpressure &
// buffering). Meta FIFO (depth META_DEPTH) holds one entry per in-flight frame;
// input is stalled if it fills (bounded, never underflows on output since every
// drained frame was metered on the way in).
//
// Assumptions: untagged Ethernet II + IPv4 (IHL honoured); even csum offset;
// contiguous tkeep; all four interfaces on one clock (xxv tx_clk_out_0).
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
`default_nettype none

module tx_csum_open #(
    parameter integer DATA_W     = 64,
    parameter integer KEEP_W     = DATA_W/8,
    parameter integer BEATCNT_W  = 12,               // frame beat index width (>=jumbo/8)
    parameter integer META_DEPTH = 32
) (
    input  wire                 aclk,
    input  wire                 aresetn,
    // input tap: mcdma -> eth_tx_fifo
    input  wire [DATA_W-1:0]    s_in_tdata,
    input  wire [KEEP_W-1:0]    s_in_tkeep,
    input  wire                 s_in_tlast,
    input  wire                 s_in_tvalid,
    output wire                 s_in_tready,
    output wire [DATA_W-1:0]    m_fifo_tdata,
    output wire [KEEP_W-1:0]    m_fifo_tkeep,
    output wire                 m_fifo_tlast,
    output wire                 m_fifo_tvalid,
    input  wire                 m_fifo_tready,
    // output tap: eth_tx_fifo -> xxv
    input  wire [DATA_W-1:0]    s_fifo_tdata,
    input  wire [KEEP_W-1:0]    s_fifo_tkeep,
    input  wire                 s_fifo_tlast,
    input  wire                 s_fifo_tvalid,
    output wire                 s_fifo_tready,
    output wire [DATA_W-1:0]    m_out_tdata,
    output wire [KEEP_W-1:0]    m_out_tkeep,
    output wire                 m_out_tlast,
    output wire                 m_out_tvalid,
    input  wire                 m_out_tready
);
    // ================= meta FIFO ==================
    localparam integer MW = 1 + BEATCNT_W + 3 + 16;  // {en, insert_beat, lane, chk}
    reg  [MW-1:0] meta [0:META_DEPTH-1];
    reg  [$clog2(META_DEPTH):0] mwr, mrd;
    wire [$clog2(META_DEPTH):0] mcnt = mwr - mrd;
    wire meta_full  = (mcnt == META_DEPTH);
    wire meta_empty = (mcnt == 0);

    // ================= input pass-through + accumulate ==================
    // stall input if meta FIFO can't take another frame's result
    // pipelined meta-push staging (fold+write happen 1 cycle after tlast)
    reg        push_pending;
    reg        push_en_r;
    reg [15:0] push_insert_r;
    reg [31:0] push_acc_r;

    // stall input if the meta FIFO can't take this frame's result (account for
    // a pipelined push still in flight - see push_pending below)
    wire in_block   = meta_full || (push_pending && (mcnt == META_DEPTH-1));
    assign m_fifo_tdata  = s_in_tdata;
    assign m_fifo_tkeep  = s_in_tkeep;
    assign m_fifo_tlast  = s_in_tlast;
    assign m_fifo_tvalid = s_in_tvalid & ~in_block;
    assign s_in_tready   = m_fifo_tready & ~in_block;
    wire in_beat = s_in_tvalid & s_in_tready;

    reg [BEATCNT_W-1:0] in_cnt;
    reg [DATA_W-1:0]    b1, b2, b3;
    reg [31:0]          acc;                          // running data-word sum
    reg [31:0]          pseudo_r;
    reg [15:0]          fs_r, fe_r, fi_r;             // start/end/insert latched
    reg                 fen_r;

    // combinational header parse (valid at in_cnt==4 with b1..b3 + current beat as b4)
    wire [DATA_W-1:0] b4c    = s_in_tdata;
    wire [15:0] ethertype = {b1[39:32], b1[47:40]};
    wire [3:0]  ip_ver    = b1[55:52];
    wire [3:0]  ip_ihl    = b1[51:48];
    wire [15:0] ip_totlen = {b2[7:0], b2[15:8]};
    wire [7:0]  ip_proto  = b2[63:56];
    wire [15:0] src_hi    = {b3[23:16], b3[31:24]};
    wire [15:0] src_lo    = {b3[39:32], b3[47:40]};
    wire [15:0] dst_hi    = {b3[55:48], b3[63:56]};
    wire [15:0] dst_lo    = {b4c[7:0], b4c[15:8]};
    wire [7:0]  ip_hlen   = {ip_ihl, 2'b00};
    wire [15:0] c_start   = 16'd14 + ip_hlen;
    wire [15:0] c_end     = 16'd14 + ip_totlen;
    wire [15:0] c_insert  = c_start + 16'd16;
    wire        c_en      = (ethertype==16'h0800) && (ip_ver==4'h4) && (ip_proto==8'h06);
    wire [31:0] c_pseudo  = src_hi + src_lo + dst_hi + dst_lo + 32'h0006 + (ip_totlen - ip_hlen);

    wire parse_now = (in_cnt == 4);
    wire [15:0] e_start  = parse_now ? c_start  : fs_r;
    wire [15:0] e_end    = parse_now ? c_end    : fe_r;
    wire [15:0] e_insert = parse_now ? c_insert : fi_r;
    wire        e_en     = parse_now ? c_en     : fen_r;

    function [7:0] mbyte;
        input [7:0] d; input keep; input [15:0] off;
        input [15:0] st; input [15:0] en; input [15:0] ins;
        begin
            mbyte = (keep && (off>=st) && (off<en) && (off!=ins) && (off!=(ins+16'd1)))
                    ? d : 8'h00;
        end
    endfunction
    function [18:0] msum;
        input [DATA_W-1:0] d; input [KEEP_W-1:0] k; input [BEATCNT_W-1:0] a;
        input [15:0] st; input [15:0] en; input [15:0] ins;
        reg [15:0] base;
        begin
            base = {a, 3'b000};
            msum = {mbyte(d[7:0],  k[0],base+0,st,en,ins), mbyte(d[15:8], k[1],base+1,st,en,ins)}
                 + {mbyte(d[23:16],k[2],base+2,st,en,ins), mbyte(d[31:24],k[3],base+3,st,en,ins)}
                 + {mbyte(d[39:32],k[4],base+4,st,en,ins), mbyte(d[47:40],k[5],base+5,st,en,ins)}
                 + {mbyte(d[55:48],k[6],base+6,st,en,ins), mbyte(d[63:56],k[7],base+7,st,en,ins)};
        end
    endfunction
    function [15:0] fold_cmpl;
        input [31:0] s; reg [31:0] t;
        begin t=(s&32'hFFFF)+(s>>16); t=(t&32'hFFFF)+(t>>16); fold_cmpl=~t[15:0]; end
    endfunction

    // this beat's data-word contribution (only beats >=4, when parse known)
    wire [18:0] beat_ms = (e_en && (in_cnt >= 4))
                          ? msum(s_in_tdata, s_in_tkeep, in_cnt, e_start, e_end, e_insert) : 19'd0;

    // Meta push is PIPELINED one cycle after tlast: the raw 32-bit sum is
    // captured at tlast, the fold + LUTRAM write happen the following cycle.
    // (fold_cmpl straight off the msum adder cone missed timing at 156.25 MHz
    // by ~0.3 ns in some placements.) Safe: frames start draining much later
    // (packet-mode eth_tx_fifo), and min frame spacing (>=9 beats) guarantees
    // the staging registers are free before the next tlast.
    always @(posedge aclk) begin
        if (!aresetn) begin
            in_cnt<=0; acc<=0; pseudo_r<=0; fs_r<=0; fe_r<=0; fi_r<=0; fen_r<=0;
            mwr<=0; push_pending<=0; push_en_r<=0; push_insert_r<=0; push_acc_r<=0;
        end else begin
            // stage 2: fold + write meta (one cycle after tlast)
            if (push_pending) begin
                meta[mwr[$clog2(META_DEPTH)-1:0]] <=
                    { push_en_r, push_insert_r[BEATCNT_W+2:3], push_insert_r[2:0],
                      fold_cmpl(push_acc_r) };
                mwr <= mwr + 1'b1;
                push_pending <= 1'b0;
            end
            // stage 1: input beat handling
            if (in_beat) begin
                if (in_cnt==12'd1) b1 <= s_in_tdata;
                if (in_cnt==12'd2) b2 <= s_in_tdata;
                if (in_cnt==12'd3) b3 <= s_in_tdata;
                if (parse_now) begin                  // latch parse @ beat4
                    fs_r<=c_start; fe_r<=c_end; fi_r<=c_insert; fen_r<=c_en; pseudo_r<=c_pseudo;
                end
                // accumulate (beats>=4 contribute; pseudo added at beat4)
                if (in_cnt >= 4)
                    acc <= acc + {13'd0, beat_ms} + ((parse_now && c_en) ? c_pseudo : 32'd0);

                if (s_in_tlast) begin
                    // capture raw sum; fold+push next cycle
                    push_en_r     <= e_en;
                    push_insert_r <= e_insert;
                    push_acc_r    <= acc + {13'd0, beat_ms}
                                     + ((in_cnt<=4 && c_en) ? c_pseudo : 32'd0);
                    push_pending  <= 1'b1;
                    in_cnt<=0; acc<=0;
                end else begin
                    in_cnt <= in_cnt + 1'b1;
                end
            end
        end
    end

    // ================= output pass-through + patch ==================
    wire [MW-1:0]        mhead      = meta[mrd[$clog2(META_DEPTH)-1:0]];
    wire                 h_en       = mhead[MW-1];
    wire [BEATCNT_W-1:0] h_insbeat  = mhead[MW-2 -: BEATCNT_W];
    wire [2:0]           h_lane     = mhead[15+3 -: 3];
    wire [15:0]          h_chk      = mhead[15:0];

    reg [BEATCNT_W-1:0] out_cnt;
    wire out_beat = s_fifo_tvalid & s_fifo_tready;
    wire ins_here = h_en && !meta_empty && (out_cnt == h_insbeat);

    reg [DATA_W-1:0] out_patched;
    always @(*) begin
        out_patched = s_fifo_tdata;
        if (ins_here) begin
            out_patched[8*h_lane        +: 8] = h_chk[15:8];
            out_patched[8*(h_lane+3'd1) +: 8] = h_chk[7:0];
        end
    end
    assign m_out_tdata  = out_patched;
    assign m_out_tkeep  = s_fifo_tkeep;
    assign m_out_tlast  = s_fifo_tlast;
    assign m_out_tvalid = s_fifo_tvalid;
    assign s_fifo_tready = m_out_tready;

    always @(posedge aclk) begin
        if (!aresetn) begin
            out_cnt<=0; mrd<=0;
        end else if (out_beat) begin
            if (s_fifo_tlast) begin
                out_cnt<=0;
                if (!meta_empty) mrd <= mrd + 1'b1;   // pop this frame's meta
            end else begin
                out_cnt <= out_cnt + 1'b1;
            end
        end
    end
endmodule
`default_nettype wire
