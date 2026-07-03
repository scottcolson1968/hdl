// -----------------------------------------------------------------------------
// open_mac_10g - open-source 10G Ethernet MAC wrapper (license-free XXV MAC
// replacement) for the Genesys ZU DAQ 10G path.
//
// Wraps verilog-ethernet's eth_mac_10g (MIT) so it drops into the block design
// between the AXIS datapath and the xxv_ethernet core reconfigured as the FREE
// "Ethernet PCS/PMA 64-bit" BASE-R PHY:
//
//   eth_tx_fifo/tx_csum_open --> s_axis_tx --> [MAC+FCS] --> xgmii_tx* --> PCS
//   PCS --> xgmii_rx* --> [MAC: FCS check/strip] --> drop-bad-frame FIFO
//       --> m_axis_rx --> eth_rx_fifo --> MCDMA
//
// * TX: MAC inserts FCS + preamble/IFG (DIC). Padding to 64B enabled.
// * RX: MAC strips preamble + FCS, flags bad-FCS/framing via tuser[0]; the
//   internal frame FIFO (16 KB, jumbo-capable) DROPS tuser-marked frames and
//   sheds load if full, so only clean frames reach the DMA (an improvement on
//   the AMD MAC + plain FIFO arrangement, which forwarded marked frames).
// * cfg_tx/rx_enable come from the xxv_shim register block (TC/RCW1 bit0),
//   quasi-static, 2FF-synced into the respective clock domains here.
//
// Clocks: tx domain = PCS tx_mii_clk_0 (156.25 MHz), rx domain = PCS
// rx_clk_out_0. m_axis_rx has NO tready (valid-only, same as the AMD MAC's
// axis_rx_0) -- downstream eth_rx_fifo absorbs, as in the original design.
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
`default_nettype none

module open_mac_10g (
    input  wire        tx_clk,
    input  wire        tx_rst,          // active-high (PCS user_tx_reset_0)
    input  wire        rx_clk,
    input  wire        rx_rst,          // active-high (PCS user_rx_reset_0)

    // AXIS TX in (from tx_csum_open m_out)
    input  wire [63:0] s_axis_tx_tdata,
    input  wire [7:0]  s_axis_tx_tkeep,
    input  wire        s_axis_tx_tvalid,
    output wire        s_axis_tx_tready,
    input  wire        s_axis_tx_tlast,

    // AXIS RX out (to eth_rx_fifo) - valid-only, no tready (as AMD MAC)
    output wire [63:0] m_axis_rx_tdata,
    output wire [7:0]  m_axis_rx_tkeep,
    output wire        m_axis_rx_tvalid,
    output wire        m_axis_rx_tlast,

    // XGMII to/from the PCS/PMA-only xxv core (mii pins)
    output wire [63:0] xgmii_txd,
    output wire [7:0]  xgmii_txc,
    input  wire [63:0] xgmii_rxd,
    input  wire [7:0]  xgmii_rxc,

    // quasi-static enables from xxv_shim (TC[0] / RCW1[0])
    input  wire        cfg_tx_enable,
    input  wire        cfg_rx_enable,

    // status
    output wire        rx_error_bad_fcs
);
    // 2FF sync of quasi-static enables into their clock domains
    (* ASYNC_REG = "true" *) reg [1:0] txen_sync, rxen_sync;
    always @(posedge tx_clk) txen_sync <= {txen_sync[0], cfg_tx_enable};
    always @(posedge rx_clk) rxen_sync <= {rxen_sync[0], cfg_rx_enable};

    wire [63:0] macrx_tdata;
    wire [7:0]  macrx_tkeep;
    wire        macrx_tvalid, macrx_tlast;
    wire        macrx_tuser;             // 1 = bad frame (FCS/framing)

    eth_mac_10g #(
        .DATA_WIDTH        (64),
        .ENABLE_PADDING    (1),
        .ENABLE_DIC        (1),
        .MIN_FRAME_LENGTH  (64),
        .PTP_TS_ENABLE     (0),
        .PFC_ENABLE        (0),
        .PAUSE_ENABLE      (0)
    ) mac_i (
        .rx_clk           (rx_clk),
        .rx_rst           (rx_rst),
        .tx_clk           (tx_clk),
        .tx_rst           (tx_rst),
        .tx_axis_tdata    (s_axis_tx_tdata),
        .tx_axis_tkeep    (s_axis_tx_tkeep),
        .tx_axis_tvalid   (s_axis_tx_tvalid),
        .tx_axis_tready   (s_axis_tx_tready),
        .tx_axis_tlast    (s_axis_tx_tlast),
        .tx_axis_tuser    (1'b0),
        .rx_axis_tdata    (macrx_tdata),
        .rx_axis_tkeep    (macrx_tkeep),
        .rx_axis_tvalid   (macrx_tvalid),
        .rx_axis_tlast    (macrx_tlast),
        .rx_axis_tuser    (macrx_tuser),
        .xgmii_rxd        (xgmii_rxd),
        .xgmii_rxc        (xgmii_rxc),
        .xgmii_txd        (xgmii_txd),
        .xgmii_txc        (xgmii_txc),
        .tx_ptp_ts        (96'd0),
        .rx_ptp_ts        (96'd0),
        .tx_axis_ptp_ts   (), .tx_axis_ptp_ts_tag(), .tx_axis_ptp_ts_valid(),
        .tx_lfc_req       (1'b0), .tx_lfc_resend(1'b0),
        .rx_lfc_en        (1'b0), .rx_lfc_req(), .rx_lfc_ack(1'b0),
        .tx_pfc_req       (8'd0), .tx_pfc_resend(1'b0),
        .rx_pfc_en        (8'd0), .rx_pfc_req(), .rx_pfc_ack(8'd0),
        .tx_lfc_pause_en  (1'b0), .tx_pause_req(1'b0), .tx_pause_ack(),
        .tx_start_packet  (), .tx_error_underflow(),
        .rx_start_packet  (), .rx_error_bad_frame(), .rx_error_bad_fcs(rx_error_bad_fcs),
        .stat_tx_mcf(), .stat_rx_mcf(),
        .stat_tx_lfc_pkt(), .stat_tx_lfc_xon(), .stat_tx_lfc_xoff(), .stat_tx_lfc_paused(),
        .stat_tx_pfc_pkt(), .stat_tx_pfc_xon(), .stat_tx_pfc_xoff(), .stat_tx_pfc_paused(),
        .stat_rx_lfc_pkt(), .stat_rx_lfc_xon(), .stat_rx_lfc_xoff(), .stat_rx_lfc_paused(),
        .stat_rx_pfc_pkt(), .stat_rx_pfc_xon(), .stat_rx_pfc_xoff(), .stat_rx_pfc_paused(),
        .cfg_ifg          (8'd12),
        .cfg_tx_enable    (txen_sync[1]),
        .cfg_rx_enable    (rxen_sync[1]),
        .cfg_mcf_rx_eth_dst_mcast(48'd0), .cfg_mcf_rx_check_eth_dst_mcast(1'b0),
        .cfg_mcf_rx_eth_dst_ucast(48'd0), .cfg_mcf_rx_check_eth_dst_ucast(1'b0),
        .cfg_mcf_rx_eth_src(48'd0),       .cfg_mcf_rx_check_eth_src(1'b0),
        .cfg_mcf_rx_eth_type(16'd0),
        .cfg_mcf_rx_opcode_lfc(16'd0),    .cfg_mcf_rx_check_opcode_lfc(1'b0),
        .cfg_mcf_rx_opcode_pfc(16'd0),    .cfg_mcf_rx_check_opcode_pfc(1'b0),
        .cfg_mcf_rx_forward(1'b0),        .cfg_mcf_rx_enable(1'b0),
        .cfg_tx_lfc_eth_dst(48'd0), .cfg_tx_lfc_eth_src(48'd0),
        .cfg_tx_lfc_eth_type(16'd0), .cfg_tx_lfc_opcode(16'd0),
        .cfg_tx_lfc_en(1'b0), .cfg_tx_lfc_quanta(16'd0), .cfg_tx_lfc_refresh(16'd0),
        .cfg_tx_pfc_eth_dst(48'd0), .cfg_tx_pfc_eth_src(48'd0),
        .cfg_tx_pfc_eth_type(16'd0), .cfg_tx_pfc_opcode(16'd0),
        .cfg_tx_pfc_en(1'b0), .cfg_tx_pfc_quanta(128'd0), .cfg_tx_pfc_refresh(128'd0),
        .cfg_rx_lfc_opcode(16'd0), .cfg_rx_lfc_en(1'b0),
        .cfg_rx_pfc_opcode(16'd0), .cfg_rx_pfc_en(1'b0)
    );

    // RX frame FIFO: drops tuser-marked (bad FCS / framing error) frames and
    // sheds when full. 16 KB = one 9K jumbo + margin. Output tready tied high
    // downstream shape (valid-only) is preserved because eth_rx_fifo absorbs.
    wire [63:0] drop_tdata;
    wire [7:0]  drop_tkeep;
    wire        drop_tvalid, drop_tlast;
    wire        drop_tuser_nc;

    axis_fifo #(
        .DEPTH               (16384),
        .DATA_WIDTH          (64),
        .KEEP_ENABLE         (1),
        .KEEP_WIDTH          (8),
        .LAST_ENABLE         (1),
        .ID_ENABLE           (0),
        .DEST_ENABLE         (0),
        .USER_ENABLE         (1),
        .USER_WIDTH          (1),
        .FRAME_FIFO          (1),
        .USER_BAD_FRAME_VALUE(1'b1),
        .USER_BAD_FRAME_MASK (1'b1),
        .DROP_OVERSIZE_FRAME (1),
        .DROP_BAD_FRAME      (1),
        .DROP_WHEN_FULL      (1)
    ) rx_drop_fifo_i (
        .clk           (rx_clk),
        .rst           (rx_rst),
        .s_axis_tdata  (macrx_tdata),
        .s_axis_tkeep  (macrx_tkeep),
        .s_axis_tvalid (macrx_tvalid),
        .s_axis_tready (),               // DROP_WHEN_FULL -> always ready
        .s_axis_tlast  (macrx_tlast),
        .s_axis_tid    (8'd0),
        .s_axis_tdest  (8'd0),
        .s_axis_tuser  (macrx_tuser),
        .m_axis_tdata  (drop_tdata),
        .m_axis_tkeep  (drop_tkeep),
        .m_axis_tvalid (drop_tvalid),
        .m_axis_tready (1'b1),
        .m_axis_tlast  (drop_tlast),
        .m_axis_tid    (),
        .m_axis_tdest  (),
        .m_axis_tuser  (drop_tuser_nc),
        .pause_req     (1'b0),
        .pause_ack     (),
        .status_depth  (),
        .status_depth_commit (),
        .status_overflow     (),
        .status_bad_frame    (),
        .status_good_frame   ()
    );

    assign m_axis_rx_tdata  = drop_tdata;
    assign m_axis_rx_tkeep  = drop_tkeep;
    assign m_axis_rx_tvalid = drop_tvalid;
    assign m_axis_rx_tlast  = drop_tlast;
endmodule
`default_nettype wire
