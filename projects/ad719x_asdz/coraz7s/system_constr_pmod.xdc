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

# coraz7s
# ad719x spi connections

# connect through the PMOD pins

set_property -dict {PACKAGE_PIN Y17 IOSTANDARD LVCMOS33} [get_ports adc_spi_sclk];      # IO_L7N_T1_34  Sch=ja_n[2]
set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS33} [get_ports adc_spi_miso_rdyn]; # IO_L7P_T1_34  Sch=ja_p[2]; AD719X sch=DOUT/RDY_N
set_property -dict {PACKAGE_PIN Y19 IOSTANDARD LVCMOS33} [get_ports adc_spi_mosi];      # IO_L17N_T2_34 Sch=ja_n[1]; AD719X sch=DIN
set_property -dict {PACKAGE_PIN Y18 IOSTANDARD LVCMOS33} [get_ports adc_spi_csn];       # IO_L17P_T2_34 Sch=ja_p[1]
