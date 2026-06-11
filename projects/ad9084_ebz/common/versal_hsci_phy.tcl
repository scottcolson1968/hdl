###############################################################################
## Copyright (C) 2025 Analog Devices, Inc. All rights reserved.
###
### In this HDL repository, there are many different and unique modules, consisting
### of various HDL (Verilog or VHDL) components. The individual modules are
### developed independently, and may be accompanied by separate and unique license
### terms.
###
### The user should read each of these license terms, and understand the
### freedoms and responsibilities that he or she has by using this source/core.
###
### This core is distributed in the hope that it will be useful, but WITHOUT ANY
### WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
### A PARTICULAR PURPOSE.
###
### Redistribution and use of source or resulting binaries, with or without modification
### of this file, are permitted under one of the following two license terms:
###
###   1. The GNU General Public License version 2 as published by the
###      Free Software Foundation, which can be found in the top level directory
###      of this repository (LICENSE_GPL2), and also online at:
###      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
###
### OR
###
###   2. An ADI specific BSD license, which can be found in the top level directory
###      of this repository (LICENSE_ADIBSD), and also on-line at:
###      https://github.com/analogdevicesinc/hdl/blob/main/LICENSE_ADIBSD
###      This will allow to generate bit files and not release the source code,
###      as long as it attaches to an ADI device.
###
### ***************************************************************************
### ***************************************************************************
###############################################################################

proc create_hsci_phy { {ip_name advanced_io_wizard_0} {num_banks 1} } {

  ad_ip_instance advanced_io_wizard ${ip_name}
  set_property -dict [list \
    CONFIG.DIFF_IO_T {DIFF_TERM_ADV} \
    CONFIG.DIFFERENTIAL_IO_TERMINATION {TERM_100} \
    CONFIG.BUS_DIR {3} \
    CONFIG.MAX_BANKS ${num_banks} \
    CONFIG.BIDIR_MODE {0} \
    CONFIG.CLK_TO_DATA_ALIGN {3} \
    CONFIG.DATA_SPEED {1600.00} \
    CONFIG.INPUT_CLK_FREQ {200.000} \
    CONFIG.ENABLE_PLLOUT1 {0} \
    CONFIG.PLL0_PLLOUTCLK1 {200.000} \
    CONFIG.SIMPLE_RIU {0} \
    CONFIG.REDUCE_CONTROL_SIG_EN {1} \
    CONFIG.BIT_PERIOD {625} \
    CONFIG.PLL_CLK {34.12539203348543} \
    CONFIG.TX_IOB {74} \
    CONFIG.TX_PHY {80} \
    CONFIG.TX_WINDOW_VAL {471} \
    CONFIG.RX_WINDOW_VAL {509} \
    CONFIG.BUS0_IO_TYPE {DIFF} \
    CONFIG.BUS0_STROBE_NAME {clk_in} \
    CONFIG.BUS0_STROBE_IO_TYPE {DIFF} \
    CONFIG.BUS0_SIG_NAME {data_in} \
    CONFIG.BUS1_DIR {TX} \
    CONFIG.BUS1_IO_TYPE {DIFF} \
    CONFIG.BUS1_SIG_NAME {data_out} \
    CONFIG.BUS2_DIR {TX} \
    CONFIG.BUS2_IO_TYPE {DIFF} \
    CONFIG.BUS2_SIG_TYPE {Clk Fwd} \
    CONFIG.BUS2_SIG_NAME {clk_out} \
    CONFIG.BUS12_WRCLK_EN {0} \
    CONFIG.DIFF_IO_STD {LVDS15} \
    CONFIG.ENABLE_BLI {0} \
  ] [get_bd_cells ${ip_name}]
}
