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

# data interface

set_property -dict {PACKAGE_PIN M19 IOSTANDARD LVCMOS25 IOB TRUE} [get_ports ltc2378_spi_sclk]; ## G6   FMC_LA00_CC_P   IO_L13P_T2_MRCC_34
set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS25 IOB TRUE} [get_ports ltc2378_spi_sdi];  ## H7   FMC_LA02_P      IO_L20P_T3_34
set_property -dict {PACKAGE_PIN L22 IOSTANDARD LVCMOS25 IOB TRUE} [get_ports ltc2378_spi_sdo];  ## C11  FMC_LA06_N      IO_L10N_T1_34
set_property -dict {PACKAGE_PIN N19 IOSTANDARD LVCMOS25} [get_ports ltc2378_spi_cnv];           ## D8   FMC_LA01_CC_P   IO_L14P_T2_SRCC_34

set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS25} [get_ports ltc2378_ext_clk];           ## H4   FMC_CLK0_M2C_P  IO_L12P_T1_MRCC_34

#set_property -dict {PACKAGE_PIN D20 IOSTANDARD LVCMOS25} [get_ports ltc2378_spi_busy];         ## C11  FMC_LA18_CC_P   IO_L14P_T2_AD4P_SRCC_35
set_property -dict {PACKAGE_PIN M20 IOSTANDARD LVCMOS25} [get_ports ltc2378_chain];             ## G7   FMC_LA00_CC_N   IO_L13N_T2_MRCC_34
set_property -dict {PACKAGE_PIN N20 IOSTANDARD LVCMOS25} [get_ports ltc2378_dcgn];              ## D9   FMC_LA01_CC_N   IO_L14N_T2_SRCC_34
# set_property -dict {PACKAGE_PIN #N/A IOSTANDARD LVCMOS25} [get_ports enable];                 ## D1   FMC_PG_C2M      #N/A

# external clock, that drives the CNV generator, must have a maximum 100 MHz frequency
create_clock -period 10.000 -name cnv_ext_clk [get_ports ltc2378_ext_clk]

# rename auto-generated clock for SPIEngine to spi_clk - 200MHz
# NOTE: clk_fpga_0 is the first PL fabric clock, also called $sys_cpu_clk
create_generated_clock -name spi_clk -source [get_pins -filter name=~*CLKIN1 -of [get_cells -hier -filter name=~*spi_clkgen*i_mmcm]] -master_clock clk_fpga_0 [get_pins -filter name=~*CLKOUT0 -of [get_cells -hier -filter name=~*spi_clkgen*i_mmcm]]

# relax the SDO path to help closing timing at high frequencies
set_multicycle_path -setup 8 -to [get_cells -hierarchical -filter {NAME=~*/data_sdo_shift_reg[*]}] -from [get_clocks spi_clk]
set_multicycle_path -hold  7 -to [get_cells -hierarchical -filter {NAME=~*/data_sdo_shift_reg[*]}] -from [get_clocks spi_clk]
set_multicycle_path -setup 8 -to [get_cells -hierarchical -filter {NAME=~*/spi_ltc2378_execution/inst/left_aligned_reg*}] -from [get_clocks spi_clk]
set_multicycle_path -hold  7 -to [get_cells -hierarchical -filter {NAME=~*/spi_ltc2378_execution/inst/left_aligned_reg*}] -from [get_clocks spi_clk]
