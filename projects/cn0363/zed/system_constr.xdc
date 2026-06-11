###############################################################################
## Copyright (C) 2015-2023 Analog Devices, Inc. All rights reserved.
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

# PMOD JA

set_property -dict {PACKAGE_PIN Y11  IOSTANDARD LVCMOS33} [get_ports gain0_o]                       ; ## PMOD JA1  
set_property -dict {PACKAGE_PIN AA11 IOSTANDARD LVCMOS33} [get_ports gain1_o]                       ; ## PMOD JA2 
set_property -dict {PACKAGE_PIN AA9  IOSTANDARD LVCMOS33} [get_ports led_clk_o]                     ; ## PMOD JA4 
set_property -dict {PACKAGE_PIN Y10  IOSTANDARD LVCMOS33} [get_ports {spi_cs[1]}]                   ; ## PMOD JA3 
set_property -dict {PACKAGE_PIN AB11 IOSTANDARD LVCMOS33} [get_ports {spi_cs[0]}]                   ; ## PMOD JA7 
set_property -dict {PACKAGE_PIN AB10 IOSTANDARD LVCMOS33 PULLUP true} [get_ports spi_sdo]           ; ## PMOD JA8 
set_property -dict {PACKAGE_PIN AB9  IOSTANDARD LVCMOS33 PULLUP true} [get_ports spi_sdi]           ; ## PMOD JA9 
set_property -dict {PACKAGE_PIN AA8  IOSTANDARD LVCMOS33} [get_ports spi_sclk]                      ; ## PMOD JA10
