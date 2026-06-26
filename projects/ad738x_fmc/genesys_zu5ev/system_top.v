// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2019-2025 Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsibilities that he or she has by using this source/core.
//
// This core is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE.
//
// Redistribution and use of source or resulting binaries, with or without modification
// of this file, are permitted under one of the following two license terms:
//
//   1. The GNU General Public License version 2 as published by the
//      Free Software Foundation, which can be found in the top level directory
//      of this repository (LICENSE_GPL2), and also online at:
//      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on-line at:
//      https://github.com/analogdevicesinc/hdl/blob/main/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`timescale 1ns/100ps

module system_top #(
  parameter ALERT_SPI_N = 0,
  parameter NUM_OF_SDI = 4
) (

  input   [ 8:0]  gpio_bd_i,
  output  [ 3:0]  gpio_bd_o,

  input           spi_sdia,
  input           spi_sdib,
  input           spi_sdic,
  input           spi_sdid,
  output          spi_sdo,
  output          spi_sclk,
  output          spi_cs,

  // Genesys ZU platform MCU VADJ request: the FPGA must drive the level
  // pins and hold VADJ_AUTO low, otherwise the MCU keeps VADJ disabled
  // (Genesys ZU RM 10.2.1.1). 2'b11 = 1.8 V for the FMC bank / EVAL VLOGIC.
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
  output          sel_sfp_not_fmc
);

  // internal signals

  wire    [94:0]  gpio_i;
  wire    [94:0]  gpio_o;
  wire            vadj_clk;

  wire [NUM_OF_SDI-1:0] ad738x_spi_sdi_s;

  // instantiations

  // Genesys ZU platform MCU manual-VADJ request: the MCU acts on a RISING
  // edge of VADJ_AUTON with the level pins stable (Digilent forum #30135,
  // confirmed on this board: AUTON ends up high = manual VADJ enabled).
  // The MCU refuses autonomous VADJ for this FMC card (EEPROM requests
  // >2.1 A -> latched fault), so the override is mandatory. Hold AUTON low
  // ~2.7 s after configuration so the MCU finishes its power-up sequence,
  // then raise it. EMIO GPIO rescue without rebuild (Linux lines 78+36/37):
  // gpio_o[37]=1 forces AUTON low, gpio_o[36]=1 forces it high -- toggling
  // 37 then 36 recreates the rising edge from software.
  reg  [28:0] vadj_arm_cnt = 29'd0;

  always @(posedge vadj_clk) begin
    if (vadj_arm_cnt[28] == 1'b0) begin
      vadj_arm_cnt <= vadj_arm_cnt + 1'b1;
    end
  end

  assign vadj_level = 2'b11;   // request VADJ = 1.8 V
  assign vadj_auton = (vadj_arm_cnt[28] & ~gpio_o[37]) | gpio_o[36];

  assign gpio_bd_o = gpio_o[3:0];

  assign gpio_i[ 3: 0] = gpio_o[3:0];
  assign gpio_i[12: 4] = gpio_bd_i;
  assign gpio_i[31:13] = gpio_o[31:13];

  assign gpio_i[32] = ALERT_SPI_N ? spi_sdib : 1'b0;
  assign gpio_i[33] = ALERT_SPI_N ? spi_sdid : 1'b0;

  // SFP+ control via PS EMIO GPIO (Linux lines 78+N):
  //   gpio_o[40] -> TX_DISABLE (EMIO resets low = transmitter enabled)
  //   gpio_i[41] <- MOD_DETECT (low = module present)
  //   gpio_i[42] <- RX_LOS
  //   gpio_i[43] <- TX_FAULT
  assign sfp_tx_disable = gpio_o[40];
  assign gpio_i[41] = sfp_mod_detect;
  assign gpio_i[42] = sfp_rx_los;
  assign gpio_i[43] = sfp_tx_fault;
  assign sfp_rs0 = 1'b1;            // full rate
  assign sfp_rs1 = 1'b1;
  assign sel_sfp_not_fmc = 1'b1;    // GTH lane mux: SFP+, not FMC GBT

  assign gpio_i[40] = gpio_o[40];
  assign gpio_i[94:44] = gpio_o[94:44];
  assign gpio_i[39:34] = gpio_o[39:34];

  assign ad738x_spi_sdi_s = (ALERT_SPI_N == 0) ? ((NUM_OF_SDI == 1) ? {spi_sdia} : ((NUM_OF_SDI == 4) ? {spi_sdid, spi_sdic, spi_sdib, spi_sdia} : {spi_sdib, spi_sdia})): spi_sdia;

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
    .spi0_csn (),
    .spi0_miso (1'b0),
    .spi0_mosi (),
    .spi0_sclk (),
    .spi1_csn (),
    .spi1_miso (1'b0),
    .spi1_mosi (),
    .spi1_sclk (),
    .ad738x_spi_sdo (spi_sdo),
    .ad738x_spi_sdo_t (),
    .ad738x_spi_sdi (ad738x_spi_sdi_s),
    .ad738x_spi_cs (spi_cs),
    .ad738x_spi_sclk (spi_sclk));

endmodule
