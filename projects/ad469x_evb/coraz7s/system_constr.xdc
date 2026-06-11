###############################################################################
## Copyright (C) 2020-2024 Analog Devices, Inc. All rights reserved.
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

# ad4696_ardz SPI interface

set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33 IOB TRUE}   [get_ports ad469x_spi_sclk];     ## CK_IO13
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33 IOB TRUE}   [get_ports ad469x_spi_sdo];      ## CK_IO12
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33 IOB TRUE}   [get_ports ad469x_spi_sdi];      ## CK_IO11
set_property -dict {PACKAGE_PIN U15 IOSTANDARD LVCMOS33 IOB TRUE}   [get_ports ad469x_spi_cs];       ## CK_IO10

set_property -dict {PACKAGE_PIN M18 IOSTANDARD LVCMOS33}            [get_ports ad469x_busy_alt_gp0]; ## CK_IO09
set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33}            [get_ports ad469x_spi_cnv];      ## CK_IO06
set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33}            [get_ports ad469x_resetn];       ## CK_IO04

# rename auto-generated clock for SPIEngine to spi_clk - 160MHz
# NOTE: clk_fpga_0 is the first PL fabric clock, also called $sys_cpu_clk
create_generated_clock -name spi_clk -source [get_pins -filter name=~*CLKIN1 -of [get_cells -hier -filter name=~*spi_clkgen*i_mmcm]] -master_clock clk_fpga_0 [get_pins -filter name=~*CLKOUT0 -of [get_cells -hier -filter name=~*spi_clkgen*i_mmcm]]

# relax the SDO path to help closing timing at high frequencies
set_multicycle_path -setup 8 -to [get_cells -hierarchical -filter {NAME=~*/data_sdo_shift_reg[*]}] -from [get_clocks spi_clk]
set_multicycle_path -hold  7 -to [get_cells -hierarchical -filter {NAME=~*/data_sdo_shift_reg[*]}] -from [get_clocks spi_clk]
set_multicycle_path -setup 8 -to [get_cells -hierarchical -filter {NAME=~*/spi_ad469x_execution/inst/left_aligned_reg*}] -from [get_clocks spi_clk]
set_multicycle_path -hold  7 -to [get_cells -hierarchical -filter {NAME=~*/spi_ad469x_execution/inst/left_aligned_reg*}] -from [get_clocks spi_clk]
