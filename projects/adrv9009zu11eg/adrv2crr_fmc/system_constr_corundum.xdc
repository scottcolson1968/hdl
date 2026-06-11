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

set_property -dict {PACKAGE_PIN  AU11 IOSTANDARD LVCMOS18 } [get_ports qsfp_resetl  ] ;
set_property -dict {PACKAGE_PIN  AL12 IOSTANDARD LVCMOS18 PULLUP true } [get_ports qsfp_modprsl ] ;
set_property -dict {PACKAGE_PIN  AW14 IOSTANDARD LVCMOS18 PULLUP true } [get_ports qsfp_intl    ] ;
set_property -dict {PACKAGE_PIN  AV11 IOSTANDARD LVCMOS18 } [get_ports qsfp_lpmode  ] ;

set_property PACKAGE_PIN AD2   [get_ports qsfp_rx_p[0] ] ;
set_property PACKAGE_PIN AD1   [get_ports qsfp_rx_n[0] ] ;

set_property PACKAGE_PIN AC4   [get_ports qsfp_rx_p[1] ] ;
set_property PACKAGE_PIN AC3   [get_ports qsfp_rx_n[1] ] ;

set_property PACKAGE_PIN AB2   [get_ports qsfp_rx_p[2] ] ;
set_property PACKAGE_PIN AB1   [get_ports qsfp_rx_n[2] ] ;

set_property PACKAGE_PIN AA4   [get_ports qsfp_rx_p[3] ] ;
set_property PACKAGE_PIN AA3   [get_ports qsfp_rx_n[3] ] ;

set_property PACKAGE_PIN AD6   [get_ports qsfp_tx_p[0] ] ;
set_property PACKAGE_PIN AD5   [get_ports qsfp_tx_n[0] ] ;

set_property PACKAGE_PIN AC8   [get_ports qsfp_tx_p[1] ] ;
set_property PACKAGE_PIN AC7   [get_ports qsfp_tx_n[1] ] ;

set_property PACKAGE_PIN AB6   [get_ports qsfp_tx_p[2] ] ;
set_property PACKAGE_PIN AB5   [get_ports qsfp_tx_n[2] ] ;

set_property PACKAGE_PIN AA8   [get_ports qsfp_tx_p[3] ] ;
set_property PACKAGE_PIN AA7   [get_ports qsfp_tx_n[3] ] ;

set_property PACKAGE_PIN AD10  [get_ports qsfp_mgt_refclk_p ] ;
set_property PACKAGE_PIN AD9   [get_ports qsfp_mgt_refclk_n ] ;


# 156.25 MHz MGT reference clock
create_clock -period 6.400 -name gt_ref_clk [get_ports qsfp_mgt_refclk_p]
