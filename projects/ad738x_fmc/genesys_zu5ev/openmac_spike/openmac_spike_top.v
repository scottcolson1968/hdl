// -----------------------------------------------------------------------------
// openmac_spike_top - license-free 10G feasibility spike
//
// Proves that xxv_ethernet configured as "Ethernet PCS/PMA 64-bit" (the FREE,
// license-less BASE-R PHY) + the open-source eth_mac_10g (verilog-ethernet,
// MIT) synthesizes AND writes a bitstream WITHOUT the XXV MAC license.
// Same GT setup as production (Quad_X0Y1 / lane X0Y7 / 156.25 MHz refclk).
//
// Not a functional design: AXIS TX tied idle, RX sunk into a keep-alive
// reduction register on a LED. The point is purely write_bitstream vs license.
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module openmac_spike_top (
    input  wire gt_refclk_p,
    input  wire gt_refclk_n,
    input  wire sfp_rxp,
    input  wire sfp_rxn,
    output wire sfp_txp,
    output wire sfp_txn,
    input  wire dclk,          // free-running DRP clock (unconstrained in spike)
    output wire led_link
);
    wire        tx_mii_clk, rx_clk;
    wire        user_tx_reset, user_rx_reset;
    wire [63:0] mii_txd, mii_rxd;
    wire [7:0]  mii_txc, mii_rxc;
    wire        block_lock;

    // ---------------- free BASE-R PCS/PMA (no license) ----------------
    xxv_pcs pcs_i (
        .gt_rxp_in_0                (sfp_rxp),
        .gt_rxn_in_0                (sfp_rxn),
        .gt_txp_out_0               (sfp_txp),
        .gt_txn_out_0               (sfp_txn),
        .gt_refclk_p                (gt_refclk_p),
        .gt_refclk_n                (gt_refclk_n),
        .gt_refclk_out              (),
        .rx_core_clk_0              (rx_clk),
        .rx_clk_out_0               (rx_clk),
        .tx_mii_clk_0               (tx_mii_clk),
        .dclk                       (dclk),
        .sys_reset                  (1'b0),
        .tx_reset_0                 (1'b0),
        .rx_reset_0                 (1'b0),
        .user_tx_reset_0            (user_tx_reset),
        .user_rx_reset_0            (user_rx_reset),
        .gtwiz_reset_tx_datapath_0  (1'b0),
        .gtwiz_reset_rx_datapath_0  (1'b0),
        .txoutclksel_in_0           (3'b101),
        .rxoutclksel_in_0           (3'b101),
        .rxrecclkout_0              (),
        .gtpowergood_out_0          (),
        .gt_loopback_in_0           (3'b000),
        .qpllreset_in_0             (1'b0),
        .tx_mii_d_0                 (mii_txd),
        .tx_mii_c_0                 (mii_txc),
        .rx_mii_d_0                 (mii_rxd),
        .rx_mii_c_0                 (mii_rxc),
        .ctl_rx_test_pattern_0      (1'b0),
        .ctl_rx_data_pattern_select_0(1'b0),
        .ctl_rx_test_pattern_enable_0(1'b0),
        .ctl_rx_prbs31_test_pattern_enable_0(1'b0),
        .ctl_tx_test_pattern_0      (1'b0),
        .ctl_tx_test_pattern_enable_0(1'b0),
        .ctl_tx_test_pattern_select_0(1'b0),
        .ctl_tx_data_pattern_select_0(1'b0),
        .ctl_tx_test_pattern_seed_a_0(58'd0),
        .ctl_tx_test_pattern_seed_b_0(58'd0),
        .ctl_tx_prbs31_test_pattern_enable_0(1'b0),
        .ctl_rx_wdt_disable_0       (1'b0),
        .stat_rx_block_lock_0       (block_lock),
        .stat_rx_framing_err_0      (),
        .stat_rx_framing_err_valid_0(),
        .stat_rx_local_fault_0      (),
        .stat_rx_valid_ctrl_code_0  (),
        .stat_rx_status_0           (),
        .stat_rx_hi_ber_0           (),
        .stat_rx_bad_code_0         (),
        .stat_rx_bad_code_valid_0   (),
        .stat_rx_error_0            (),
        .stat_rx_error_valid_0      (),
        .stat_rx_fifo_error_0       (),
        .stat_tx_local_fault_0      ()
    );

    // ---------------- open-source 10G MAC (MIT) ----------------
    wire [63:0] rx_axis_tdata;
    wire [7:0]  rx_axis_tkeep;
    wire        rx_axis_tvalid, rx_axis_tlast;
    wire        rx_axis_tuser;

    (* DONT_TOUCH = "true" *)
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
        .rx_rst           (user_rx_reset),
        .tx_clk           (tx_mii_clk),
        .tx_rst           (user_tx_reset),
        // AXIS TX: idle in the spike
        .tx_axis_tdata    (64'd0),
        .tx_axis_tkeep    (8'd0),
        .tx_axis_tvalid   (1'b0),
        .tx_axis_tready   (),
        .tx_axis_tlast    (1'b0),
        .tx_axis_tuser    (1'b0),
        // AXIS RX: sink
        .rx_axis_tdata    (rx_axis_tdata),
        .rx_axis_tkeep    (rx_axis_tkeep),
        .rx_axis_tvalid   (rx_axis_tvalid),
        .rx_axis_tlast    (rx_axis_tlast),
        .rx_axis_tuser    (rx_axis_tuser),
        // XGMII <-> PCS mii
        .xgmii_rxd        (mii_rxd),
        .xgmii_rxc        (mii_rxc),
        .xgmii_txd        (mii_txd),
        .xgmii_txc        (mii_txc),
        // PTP off
        .tx_ptp_ts        (96'd0),
        .rx_ptp_ts        (96'd0),
        .tx_axis_ptp_ts   (),
        .tx_axis_ptp_ts_tag(),
        .tx_axis_ptp_ts_valid(),
        // pause/PFC off
        .tx_lfc_req       (1'b0),
        .tx_lfc_resend    (1'b0),
        .rx_lfc_en        (1'b0),
        .rx_lfc_req       (),
        .rx_lfc_ack       (1'b0),
        .tx_pfc_req       (8'd0),
        .tx_pfc_resend    (1'b0),
        .rx_pfc_en        (8'd0),
        .rx_pfc_req       (),
        .rx_pfc_ack       (8'd0),
        .tx_lfc_pause_en  (1'b0),
        .tx_pause_req     (1'b0),
        .tx_pause_ack     (),
        // status (open)
        .tx_start_packet  (),
        .tx_error_underflow(),
        .rx_start_packet  (),
        .rx_error_bad_frame(),
        .rx_error_bad_fcs (),
        .stat_tx_mcf(), .stat_rx_mcf(),
        .stat_tx_lfc_pkt(), .stat_tx_lfc_xon(), .stat_tx_lfc_xoff(), .stat_tx_lfc_paused(),
        .stat_tx_pfc_pkt(), .stat_tx_pfc_xon(), .stat_tx_pfc_xoff(), .stat_tx_pfc_paused(),
        .stat_rx_lfc_pkt(), .stat_rx_lfc_xon(), .stat_rx_lfc_xoff(), .stat_rx_lfc_paused(),
        .stat_rx_pfc_pkt(), .stat_rx_pfc_xon(), .stat_rx_pfc_xoff(), .stat_rx_pfc_paused(),
        // config
        .cfg_ifg          (8'd12),
        .cfg_tx_enable    (1'b1),
        .cfg_rx_enable    (1'b1),
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

    // keep the RX path alive: reduction of the received stream onto a LED
    reg keep;
    always @(posedge rx_clk)
        if (rx_axis_tvalid) keep <= ^{rx_axis_tdata, rx_axis_tkeep, rx_axis_tlast, rx_axis_tuser};
    assign led_link = block_lock ^ keep;
endmodule
