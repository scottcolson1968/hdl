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

set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS25} [get_ports {ad463x_spi_sdi[0]}]       ; ## H07  FMC_LA02_P
set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS25} [get_ports {ad463x_spi_sdi[1]}]       ; ## H08  FMC_LA02_N
set_property -dict {PACKAGE_PIN M21 IOSTANDARD LVCMOS25} [get_ports {ad463x_spi_sdi[2]}]       ; ## H10  FMC_LA04_P
set_property -dict {PACKAGE_PIN M22 IOSTANDARD LVCMOS25} [get_ports {ad463x_spi_sdi[3]}]       ; ## H11  FMC_LA04_N

# input delays for MISO lines (SDO for the device)
# data is latched on negative edge

set tsetup 5.6
set thold 1.4

set_input_delay -clock [get_clocks ECHOSCLK_clk] -clock_fall -max $tsetup [get_ports {ad463x_spi_sdi[0]}]
set_input_delay -clock [get_clocks ECHOSCLK_clk] -clock_fall -min $thold [get_ports {ad463x_spi_sdi[0]}]
set_input_delay -clock [get_clocks ECHOSCLK_clk] -clock_fall -max $tsetup [get_ports {ad463x_spi_sdi[1]}]
set_input_delay -clock [get_clocks ECHOSCLK_clk] -clock_fall -min $thold [get_ports {ad463x_spi_sdi[1]}]
set_input_delay -clock [get_clocks ECHOSCLK_clk] -clock_fall -max $tsetup [get_ports {ad463x_spi_sdi[2]}]
set_input_delay -clock [get_clocks ECHOSCLK_clk] -clock_fall -min $thold [get_ports {ad463x_spi_sdi[2]}]
set_input_delay -clock [get_clocks ECHOSCLK_clk] -clock_fall -max $tsetup [get_ports {ad463x_spi_sdi[3]}]
set_input_delay -clock [get_clocks ECHOSCLK_clk] -clock_fall -min $thold [get_ports {ad463x_spi_sdi[3]}]
