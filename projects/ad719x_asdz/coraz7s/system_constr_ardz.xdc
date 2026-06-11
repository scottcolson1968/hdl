###############################################################################
## Copyright (C) 2022-2025 Analog Devices, Inc. All rights reserved.
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

# coraz7s
# ad719x spi connections

# connect through the Arduino header

set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33} [get_ports adc_spi_sclk];        # IO_L19N_T3_VREF_35 Sch=ck_io[13]
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports adc_spi_miso_rdyn];   # IO_L14P_T2_AD4P_SRCC_35 Sch=ck_io[12]
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports adc_spi_mosi];        # IO_L12N_T1_MRCC_35 Sch=ck_io[11]
set_property -dict {PACKAGE_PIN U15 IOSTANDARD LVCMOS33} [get_ports adc_spi_csn];         # IO_L11N_T1_SRCC_34 Sch=ck_io[10]
set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports adc_syncn];           # IO_L21P_T3_DQS_34 Sch=ck_io[4]
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports adc_int];             # IO_L5P_T0_34 Sch=ck_io[2]
