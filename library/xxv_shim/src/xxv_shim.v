// -----------------------------------------------------------------------------
// Copyright (c) 2026 Spectral Dynamics
//
// SPDX-License-Identifier: MIT
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// xxv_shim - AXI4-Lite register shim emulating the XXV Ethernet MAC registers
//
// Mapped at the address the licensed XXV MAC used to occupy (0xA0060000) so
// the stock xilinx_axienet driver (mactype XAXIENET_10G_25G) runs UNCHANGED
// against the open-source MAC. Implements exactly the registers the driver
// touches (audited against ADI 6.12 xilinx_axienet_main.c):
//
//   0x000 GT_RESET      RW scratch (driver pulses bit0 around reset; the real
//                       GT reset is handled by the BD reset topology)
//   0x00C TC            RW scratch, reset 0x3; bit0 -> cfg_tx_enable (live)
//   0x014 RCW1          RW scratch, reset 0x3; bit0 -> cfg_rx_enable (live)
//   0x018 JUM           RW scratch (jumbo cfg; open MAC needs none)
//   0x020 TICKREG       RW scratch (stats tick; statistics are disabled)
//   0x024 REVISION      RO 0x0000_0204 ("4.2": >=3.2 so driver polls GTWIZ,
//                       which reports done immediately)
//   0x0C8 USXGMII_AN    RW scratch (USXGMII unused; BASE-R fixed-link)
//   0x0E0 AN_CTL1       RW scratch (autoneg off: no xlnx,has-auto-neg in DT)
//   0x40C STATRX_BLKLCK RO bit0 = live PCS stat_rx_block_lock (2FF-synced)
//   0x458 STAT_AN_STS   RO 0 (only read when lp->auto_neg)
//   0x498 CORE_SPEED    RO 0x1 (10G, not runtime-switchable)
//   0x4A0 STAT_GTWIZ    RO 0x3 (GT wizard resets done)
//   everything else     reads 0, writes ignored
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
`default_nettype none

module xxv_shim (
    input  wire        s_axi_aclk,
    input  wire        s_axi_aresetn,
    // AXI4-Lite slave
    input  wire [11:0] s_axi_awaddr,
    input  wire        s_axi_awvalid,
    output reg         s_axi_awready,
    input  wire [31:0] s_axi_wdata,
    input  wire [3:0]  s_axi_wstrb,
    input  wire        s_axi_wvalid,
    output reg         s_axi_wready,
    output reg  [1:0]  s_axi_bresp,
    output reg         s_axi_bvalid,
    input  wire        s_axi_bready,
    input  wire [11:0] s_axi_araddr,
    input  wire        s_axi_arvalid,
    output reg         s_axi_arready,
    output reg  [31:0] s_axi_rdata,
    output reg  [1:0]  s_axi_rresp,
    output reg         s_axi_rvalid,
    input  wire        s_axi_rready,
    // fabric hooks
    input  wire        block_lock,       // PCS stat_rx_block_lock_0 (rx_clk domain)
    output wire        cfg_tx_enable,    // TC[0]
    output wire        cfg_rx_enable     // RCW1[0]
);
    // scratch registers
    reg [31:0] r_gtrst, r_tc, r_rcw1, r_jum, r_tick, r_usxg, r_anctl;

    assign cfg_tx_enable = r_tc[0];
    assign cfg_rx_enable = r_rcw1[0];

    // block_lock CDC into AXI clock
    (* ASYNC_REG = "true" *) reg [1:0] blk_sync;
    always @(posedge s_axi_aclk) blk_sync <= {blk_sync[0], block_lock};

    // ---- write channel (simple, one beat at a time) ----
    reg        aw_hs, w_hs;
    reg [11:0] awaddr_q;
    reg [31:0] wdata_q;

    always @(posedge s_axi_aclk) begin
        if (!s_axi_aresetn) begin
            s_axi_awready<=0; s_axi_wready<=0; s_axi_bvalid<=0; s_axi_bresp<=0;
            aw_hs<=0; w_hs<=0; awaddr_q<=0; wdata_q<=0;
            r_gtrst<=0; r_tc<=32'h3; r_rcw1<=32'h3; r_jum<=0; r_tick<=0;
            r_usxg<=0; r_anctl<=0;
        end else begin
            // accept address / data independently
            s_axi_awready <= !aw_hs && s_axi_awvalid && !s_axi_bvalid;
            if (s_axi_awvalid && s_axi_awready) begin awaddr_q<=s_axi_awaddr; aw_hs<=1; end
            s_axi_wready <= !w_hs && s_axi_wvalid && !s_axi_bvalid;
            if (s_axi_wvalid && s_axi_wready) begin wdata_q<=s_axi_wdata; w_hs<=1; end

            if (aw_hs && w_hs && !s_axi_bvalid) begin
                case (awaddr_q)
                    12'h000: r_gtrst <= wdata_q;
                    12'h00C: r_tc    <= wdata_q;
                    12'h014: r_rcw1  <= wdata_q;
                    12'h018: r_jum   <= wdata_q;
                    12'h020: r_tick  <= wdata_q;
                    12'h0C8: r_usxg  <= wdata_q;
                    12'h0E0: r_anctl <= wdata_q;
                    default: ;                      // write ignored
                endcase
                s_axi_bresp  <= 2'b00;              // OKAY
                s_axi_bvalid <= 1;
                aw_hs<=0; w_hs<=0;
            end
            if (s_axi_bvalid && s_axi_bready) s_axi_bvalid <= 0;
        end
    end

    // ---- read channel ----
    always @(posedge s_axi_aclk) begin
        if (!s_axi_aresetn) begin
            s_axi_arready<=0; s_axi_rvalid<=0; s_axi_rdata<=0; s_axi_rresp<=0;
        end else begin
            s_axi_arready <= s_axi_arvalid && !s_axi_rvalid && !s_axi_arready;
            if (s_axi_arvalid && s_axi_arready) begin
                case (s_axi_araddr)
                    12'h000: s_axi_rdata <= r_gtrst;
                    12'h00C: s_axi_rdata <= r_tc;
                    12'h014: s_axi_rdata <= r_rcw1;
                    12'h018: s_axi_rdata <= r_jum;
                    12'h020: s_axi_rdata <= r_tick;
                    12'h024: s_axi_rdata <= 32'h0000_0204;         // REVISION 4.2
                    12'h0C8: s_axi_rdata <= r_usxg;
                    12'h0E0: s_axi_rdata <= r_anctl;
                    12'h40C: s_axi_rdata <= {31'd0, blk_sync[1]};  // BLKLCK
                    12'h458: s_axi_rdata <= 32'h0;                 // AN_STS
                    12'h498: s_axi_rdata <= 32'h1;                 // 10G, no RTSW
                    12'h4A0: s_axi_rdata <= 32'h3;                 // GTWIZ done
                    default: s_axi_rdata <= 32'h0;
                endcase
                s_axi_rresp  <= 2'b00;
                s_axi_rvalid <= 1;
            end
            if (s_axi_rvalid && s_axi_rready) s_axi_rvalid <= 0;
        end
    end
endmodule
`default_nettype wire
