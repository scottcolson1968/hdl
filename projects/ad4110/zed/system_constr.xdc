###############################################################################
## Copyright (C) 2022-2023 Analog Devices, Inc. All rights reserved.
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

set_property  -dict {PACKAGE_PIN  Y11    IOSTANDARD LVCMOS33} [get_ports spi_csn];       # "JA1"
set_property  -dict {PACKAGE_PIN  AA8    IOSTANDARD LVCMOS33} [get_ports spi_clk];       # "JA10"
set_property  -dict {PACKAGE_PIN  AA11   IOSTANDARD LVCMOS33} [get_ports spi_mosi];      # "JA2"
set_property  -dict {PACKAGE_PIN  Y10    IOSTANDARD LVCMOS33} [get_ports spi_miso];      # "JA3"

set_property  -dict {PACKAGE_PIN  W12    IOSTANDARD LVCMOS33} [get_ports pmod_gpio[0]];  # "JB1"
set_property  -dict {PACKAGE_PIN  W11    IOSTANDARD LVCMOS33} [get_ports pmod_gpio[1]];  # "JB2"
set_property  -dict {PACKAGE_PIN  V10    IOSTANDARD LVCMOS33} [get_ports pmod_gpio[2]];  # "JB3"
set_property  -dict {PACKAGE_PIN  W8     IOSTANDARD LVCMOS33} [get_ports pmod_gpio[3]];  # "JB4"
