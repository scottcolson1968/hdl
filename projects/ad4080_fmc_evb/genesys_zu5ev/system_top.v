// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2024-2025 Analog Devices, Inc. All rights reserved.
//
// Wildcat2 top level : EVAL-AD4080-FMC on Digilent Genesys ZU-5EV.
//
// Backhaul (VADJ manual-override arm, RGB status LED, 10G SFP+, board GPIO,
// EMIO GPIO map) is carried over verbatim from the Wildcat ad738x genesys_zu5ev
// port. The ADC front-end (AD4080 LVDS DCO/DA/DB + CNV, AD4080 control SPI on
// PS SPI0, AD9508/ADF4350 clock SPI on PS SPI1, and the eval-board power/enable
// GPIOs) replaces the ad738x SPI-Engine front-end.
//
// Distributed under the GPL-2.0 / ADI-BSD dual license (see LICENSE_* in the
// repository root).
// ***************************************************************************
// ***************************************************************************

`timescale 1ns/100ps

module system_top #(
  parameter ADC_N_BITS = 20
) (

  input   [ 8:0]  gpio_bd_i,
  output  [ 3:0]  gpio_bd_o,

  // RGB status LED (LD5), driven from PS EMIO GPIO o[46:44]
  output          ld5_r,
  output          ld5_g,
  output          ld5_b,

  // Genesys ZU platform MCU VADJ request (see arm logic below).
  output  [ 1:0]  vadj_level,
  output          vadj_auton,

  // 10G SFP+ (GTH bank 224 ch3; refclk = Si5342 @ 156.25 MHz)
  input           gt_refclk_p,
  input           gt_refclk_n,
  input           sfp_rxp,
  input           sfp_rxn,
  output          sfp_txp,
  output          sfp_txn,
  input           sfp_mod_detect,
  output          sfp_rs0,
  output          sfp_rs1,
  input           sfp_rx_los,
  output          sfp_tx_disable,
  input           sfp_tx_fault,
  output          sel_sfp_not_fmc,

  // ===================== AD4080 front-end (FMC LPC) =====================
  // LVDS data interface
  input           dco_p,
  input           dco_n,
  input           da_p,
  input           da_n,
  input           db_p,
  input           db_n,

  // eval-board reference clocks (LVDS)
  input           fpgaclk_p,
  input           fpgaclk_n,
  input           clk_p,
  input           clk_n,

  // eval-board direction / status GPIOs
  input           gpio1_fmc,      // -> filter_data_ready_n
  output          gpio2_fmc,
  input           gpio3_fmc,
  output          gp0_dir,
  output          gp1_dir,
  output          gp2_dir,
  output          gp3_dir,

  // eval-board power / clock-enable
  input           pwrgd,
  input           adf435x_lock,
  output          en_psu,
  output          pd_v33b,
  output          osc_en,
  output          ad9508_sync,

  // AD4080 control SPI (PS SPI0)
  input           ad4080_miso,
  output          ad4080_sclk,
  output          ad4080_csn,
  output          ad4080_mosi,

  // Clock generator SPI (AD9508 + ADF4350, PS SPI1)
  input           ad9508_adf4350_miso,
  output          ad9508_adf4350_sclk,
  output          ad9508_adf4350_mosi,
  output          ad9508_csn,
  output          adf4350_csn
);

  // internal signals
  wire    [94:0]  gpio_i;
  wire    [94:0]  gpio_o;
  wire    [ 2:0]  rgb_led_o;
  wire            vadj_clk;

  wire    [ 2:0]  spi0_csn;
  wire            spi0_sclk;
  wire            spi0_mosi;
  wire    [ 2:0]  spi1_csn;
  wire            spi1_sclk;
  wire            spi1_mosi;

  wire            fpga_ref_clk;
  wire            fpga_100_clk;
  wire            filter_data_ready_n;

  // ---- Genesys ZU platform MCU manual-VADJ request (identical to Wildcat) --
  // The MCU acts on a RISING edge of VADJ_AUTON with the level pins stable.
  // Hold AUTON low ~2.7 s after configuration, then raise it. EMIO rescue:
  // gpio_o[37]=1 forces AUTON low, gpio_o[36]=1 forces it high.
  reg  [28:0] vadj_arm_cnt = 29'd0;
  always @(posedge vadj_clk) begin
    if (vadj_arm_cnt[28] == 1'b0) begin
      vadj_arm_cnt <= vadj_arm_cnt + 1'b1;
    end
  end
  assign vadj_level = 2'b11;   // request VADJ = 1.8 V  (TODO: confirm AD4080 VLOGIC/VIO)
  assign vadj_auton = (vadj_arm_cnt[28] & ~gpio_o[37]) | gpio_o[36];

  assign gpio_bd_o = gpio_o[3:0];

  // RGB status LED (LD5) <- dedicated AXI GPIO (PL @0xa0080000) via rgb_led_o.
  assign ld5_r = rgb_led_o[0];
  assign ld5_g = rgb_led_o[1];
  assign ld5_b = rgb_led_o[2];

  // ---- eval-board reference clocks ----
  IBUFDS i_fpga_clk     (.I (clk_p),     .IB (clk_n),     .O (fpga_ref_clk));
  IBUFDS i_fpga_100_clk (.I (fpgaclk_p), .IB (fpgaclk_n), .O (fpga_100_clk));

  // ---- eval-board static direction / power straps (from AD4080 zed top) ----
  assign gp0_dir = 1'b0;
  assign gp1_dir = 1'b0;
  assign gp2_dir = 1'b1;
  assign gp3_dir = 1'b0;
  assign en_psu  = 1'b1;
  assign osc_en  = pwrgd;
  assign pd_v33b = 1'b1;

  // filter_data_ready comes in on gpio1_fmc and feeds axi_ad408x.
  assign filter_data_ready_n = gpio1_fmc;

  // ---- EMIO GPIO map ----
  // [3:0]   board LEDs (loopback)          [12:4]  board buttons/switches (gpio_bd_i)
  // [36]/[37] VADJ rescue high/low         [40]    SFP TX_DISABLE
  // [41] SFP MOD_DETECT  [42] RX_LOS  [43] TX_FAULT
  //
  // AD4080 eval-board controls occupy a dedicated block [50:44]; the exact
  // line numbers MUST match the Linux device tree (gpio-hog / spi cs / clock
  // driver).  TODO: align with the Wildcat2 DT before hardware bring-up.
  assign gpio_i[ 3: 0] = gpio_o[3:0];
  assign gpio_i[12: 4] = gpio_bd_i;
  assign gpio_i[31:13] = gpio_o[31:13];
  assign gpio_i[33:32] = gpio_o[33:32];

  // eval-board status back to PS
  assign gpio2_fmc     = gpio_o[33];
  assign gpio_i[34]    = gpio3_fmc;
  assign gpio_i[35]    = adf435x_lock;
  assign gpio_i[36]    = gpio_o[36];
  assign gpio_i[37]    = gpio_o[37];
  assign gpio_i[38]    = pwrgd;
  assign gpio_i[39]    = gpio_o[39];

  // ad9508 sync-request out (active per eval board: inverted EMIO line)
  assign ad9508_sync   = ~gpio_o[45];

  // SFP+ control (same lines as Wildcat)
  assign sfp_tx_disable  = gpio_o[40];
  assign gpio_i[40]      = gpio_o[40];
  assign gpio_i[41]      = sfp_mod_detect;
  assign gpio_i[42]      = sfp_rx_los;
  assign gpio_i[43]      = sfp_tx_fault;
  assign sfp_rs0         = 1'b1;
  assign sfp_rs1         = 1'b1;
  assign sel_sfp_not_fmc = 1'b1;

  assign gpio_i[94:44]   = gpio_o[94:44];

  // ---- PS SPI0 -> AD4080 control ; PS SPI1 -> AD9508/ADF4350 clock ----
  assign ad4080_sclk         = spi0_sclk;
  assign ad4080_mosi         = spi0_mosi;
  assign ad4080_csn          = spi0_csn[0];
  assign ad9508_adf4350_sclk = spi1_sclk;
  assign ad9508_adf4350_mosi = spi1_mosi;
  assign ad9508_csn          = spi1_csn[0];
  assign adf4350_csn         = spi1_csn[1];

  system_wrapper i_system_wrapper (
    .gt_refclk_p (gt_refclk_p),
    .gt_refclk_n (gt_refclk_n),
    .sfp_rxp (sfp_rxp),
    .sfp_rxn (sfp_rxn),
    .sfp_txp (sfp_txp),
    .sfp_txn (sfp_txn),
    .vadj_clk (vadj_clk),
    .gpio_i (gpio_i),
    .gpio_o (gpio_o),
    .gpio_t (),
    .rgb_led_o (rgb_led_o),

    // AD4080 control SPI on PS SPI0
    .spi0_csn (spi0_csn),
    .spi0_sclk (spi0_sclk),
    .spi0_mosi (spi0_mosi),
    .spi0_miso (ad4080_miso),
    // clock-gen SPI on PS SPI1
    .spi1_csn (spi1_csn),
    .spi1_sclk (spi1_sclk),
    .spi1_mosi (spi1_mosi),
    .spi1_miso (ad9508_adf4350_miso),

    // AD4080 LVDS front-end
    .dco_p (dco_p),
    .dco_n (dco_n),
    .da_p (da_p),
    .da_n (da_n),
    .db_p (db_p),
    .db_n (db_n),
    .sync_n (ad9508_sync),
    .filter_data_ready_n (filter_data_ready_n),
    .fpga_ref_clk (fpga_ref_clk),
    .fpga_100_clk (fpga_100_clk));

endmodule
