###############################################################################
## Copyright (C) 2014-2023, 2025 Analog Devices, Inc. All rights reserved.
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

# ad9467

set_property -dict {PACKAGE_PIN L18     IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_clk_in_p]         ; ## H4   FMC_LPC_CLK0_M2C_P
set_property -dict {PACKAGE_PIN L19     IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_clk_in_n]         ; ## H5   FMC_LPC_CLK0_M2C_N
set_property -dict {PACKAGE_PIN J21     IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_or_p]        ; ## G12  FMC_LPC_LA08_P
set_property -dict {PACKAGE_PIN J22     IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_or_n]        ; ## G13  FMC_LPC_LA08_N
set_property -dict {PACKAGE_PIN M20     IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_in_n[0]]     ; ## G7   FMC_LPC_LA00_CC_N
set_property -dict {PACKAGE_PIN M19     IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_in_p[0]]     ; ## G6   FMC_LPC_LA00_CC_P
set_property -dict {PACKAGE_PIN N19     IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_in_p[1]]     ; ## D8   FMC_LPC_LA01_CC_P
set_property -dict {PACKAGE_PIN N20     IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_in_n[1]]     ; ## D9   FMC_LPC_LA01_CC_N
set_property -dict {PACKAGE_PIN P17     IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_in_p[2]]     ; ## H7   FMC_LPC_LA02_P
set_property -dict {PACKAGE_PIN P18     IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_in_n[2]]     ; ## H8   FMC_LPC_LA02_N
set_property -dict {PACKAGE_PIN N22     IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_in_p[3]]     ; ## G9   FMC_LPC_LA03_P
set_property -dict {PACKAGE_PIN P22     IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_in_n[3]]     ; ## G10  FMC_LPC_LA03_N
set_property -dict {PACKAGE_PIN M21     IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_in_p[4]]     ; ## H10  FMC_LPC_LA04_P
set_property -dict {PACKAGE_PIN M22     IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_in_n[4]]     ; ## H11  FMC_LPC_LA04_N
set_property -dict {PACKAGE_PIN J18     IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_in_p[5]]     ; ## D11  FMC_LPC_LA05_P
set_property -dict {PACKAGE_PIN K18     IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_in_n[5]]     ; ## D12  FMC_LPC_LA05_N
set_property -dict {PACKAGE_PIN L21     IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_in_p[6]]     ; ## C10  FMC_LPC_LA06_P
set_property -dict {PACKAGE_PIN L22     IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_in_n[6]]     ; ## C11  FMC_LPC_LA06_N
set_property -dict {PACKAGE_PIN T16     IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_in_p[7]]     ; ## H13  FMC_LPC_LA07_P
set_property -dict {PACKAGE_PIN T17     IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_in_n[7]]     ; ## H14  FMC_LPC_LA07_N

## spi

set_property -dict {PACKAGE_PIN B22     IOSTANDARD LVCMOS25} [get_ports spi_csn_adc]                        ; ## G37  FMC_LPC_LA33_N
set_property -dict {PACKAGE_PIN B21     IOSTANDARD LVCMOS25} [get_ports spi_csn_clk]                        ; ## G36  FMC_LPC_LA33_P
set_property -dict {PACKAGE_PIN A22     IOSTANDARD LVCMOS25} [get_ports spi_clk]                            ; ## H38  FMC_LPC_LA32_N
set_property -dict {PACKAGE_PIN A21     IOSTANDARD LVCMOS25} [get_ports spi_sdio]                           ; ## H37  FMC_LPC_LA32_P

# clocks
create_clock -name adc_clk      -period 4.00 [get_ports adc_clk_in_p]

