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

# DAC SPI interface
set_property -dict {PACKAGE_PIN H15  IOSTANDARD LVCMOS33} [get_ports spi_sck]           ; ## ck_sck H15
set_property -dict {PACKAGE_PIN T12  IOSTANDARD LVCMOS33} [get_ports spi_sdo]           ; ## ck_mosi T12
set_property -dict {PACKAGE_PIN W15  IOSTANDARD LVCMOS33} [get_ports spi_sdi]           ; ## ck_miso W15
set_property -dict {PACKAGE_PIN F16  IOSTANDARD LVCMOS33} [get_ports spi_csb]           ; ## ck_ss F16

# DAC GPIO interface
set_property -dict {PACKAGE_PIN V13  IOSTANDARD LVCMOS33} [get_ports dac_resetb]        ; ## ck_io[1] V13
set_property -dict {PACKAGE_PIN T14  IOSTANDARD LVCMOS33} [get_ports dac_ldacb]         ; ## ck_io[2] T14
