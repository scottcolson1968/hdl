###############################################################################
## Copyright (C) 2019-2023 Analog Devices, Inc. All rights reserved.
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

# SPI interface

set_property -dict {PACKAGE_PIN J17  IOSTANDARD LVCMOS25} [get_ports spi_sclk]   ; ## FMC_LA15_N IO_L2N_T0_34
set_property -dict {PACKAGE_PIN K21  IOSTANDARD LVCMOS25} [get_ports spi_sdo]    ; ## FMC_LA16_N IO_L9N_T1_DQS_34
set_property -dict {PACKAGE_PIN N18  IOSTANDARD LVCMOS25} [get_ports spi_sdi]    ; ## FMC_LA11_N IO_L5N_T0_34
set_property -dict {PACKAGE_PIN J16  IOSTANDARD LVCMOS25} [get_ports spi_cs]     ; ## FMC_LA15_P IO_L2P_T0_34

# reset signal

set_property -dict {PACKAGE_PIN E19  IOSTANDARD LVCMOS25} [get_ports reset]      ; ## FMC_LA21_P IO_L21P_T3_DQS_AD14P_35
