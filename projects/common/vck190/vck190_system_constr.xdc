###############################################################################
## Copyright (C) 2021-2023 Analog Devices, Inc. All rights reserved.
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

create_clock -period 5.000 -name sys_clk_p [get_ports sys_clk_p]


set_property	PACKAGE_PIN	AF43 	[get_ports sys_clk_n]
set_property	PACKAGE_PIN	AE42	[get_ports sys_clk_p]

# Define SPI clock
create_clock -name spi0_clk      -period 40   [get_pins -hier */EMIOSPI0SCLKO*]
create_clock -name spi1_clk      -period 40   [get_pins -hier */EMIOSPI1SCLKO*]

# GPIOs
# (switches, leds and such)
set_property -dict {PACKAGE_PIN H34 IOSTANDARD LVCMOS18} [get_ports gpio_led[0]] ; # DS6
set_property -dict {PACKAGE_PIN J33 IOSTANDARD LVCMOS18} [get_ports gpio_led[1]] ; # DS5
set_property -dict {PACKAGE_PIN K36 IOSTANDARD LVCMOS18} [get_ports gpio_led[2]] ; # DS4
set_property -dict {PACKAGE_PIN L35 IOSTANDARD LVCMOS18} [get_ports gpio_led[3]] ; # DS3

set_property -dict {PACKAGE_PIN J35 IOSTANDARD LVCMOS18} [get_ports gpio_dip_sw[0]] ; # SW6.1
set_property -dict {PACKAGE_PIN J34 IOSTANDARD LVCMOS18} [get_ports gpio_dip_sw[1]] ; # SW6.2
set_property -dict {PACKAGE_PIN H37 IOSTANDARD LVCMOS18} [get_ports gpio_dip_sw[2]] ; # SW6.3
set_property -dict {PACKAGE_PIN H36 IOSTANDARD LVCMOS18} [get_ports gpio_dip_sw[3]] ; # SW6.4

set_property -dict {PACKAGE_PIN G37 IOSTANDARD LVCMOS18} [get_ports gpio_pb[0]] ; # SW4
set_property -dict {PACKAGE_PIN G36 IOSTANDARD LVCMOS18} [get_ports gpio_pb[1]] ; # SW5
