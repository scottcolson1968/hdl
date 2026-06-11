###############################################################################
## Copyright (C) 2022-2024 Analog Devices, Inc. All rights reserved.
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

set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports cn0561_spi_sdi]     ; ## FMC_LPC_LA03_P
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports cn0561_spi_sdo]     ; ## FMC_LPC_LA04_N
set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33} [get_ports cn0561_spi_sclk]    ; ## FMC_LPC_LA01_P_CC
set_property -dict {PACKAGE_PIN U15 IOSTANDARD LVCMOS33} [get_ports cn0561_spi_cs]      ; ## FMC_LPC_LA05_P

set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports cn0561_dclk]        ; ## FMC_LPC_CLK0_M2C_P
set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports cn0561_din[0]]      ; ## FMC_LPC_LA00_N_CC
set_property -dict {PACKAGE_PIN V18 IOSTANDARD LVCMOS33} [get_ports cn0561_din[1]]      ; ## FMC_LPC_LA06_N
set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports cn0561_din[2]]      ; ## FMC_LPC_LA02_P
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports cn0561_din[3]]      ; ## FMC_LPC_LA02_N
set_property -dict {PACKAGE_PIN T15 IOSTANDARD LVCMOS33} [get_ports cn0561_odr]         ; ## FMC_LPC_LA00_P_CC

set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33} [get_ports cn0561_pdn]         ; ## FMC_LPC_LA07_P
