###############################################################################
## Copyright (C) 2016-2023 Analog Devices, Inc. All rights reserved.
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

set_property ASYNC_REG TRUE \
  [get_cells -hier *dma_mem_*_m*] \
  [get_cells -hier *axi_xfer_*_m*] \
  [get_cells -hier *axi_mem_*_m*] \
  [get_cells -hier *axi_dma_*_m*] \
  [get_cells -hier *dac_mem_*_m*] \
  [get_cells -hier *dac_xfer_*_m*] \
  [get_cells -hier *dac_last_*_m*] \
  [get_cells -hier *dac_bypass_m*]

# AXI clk to DMA clk
set_false_path -from [get_cells  -hier -filter {name =~ */axi_mem_raddr_g* && IS_SEQUENTIAL}] \
               -to   [get_cells  -hier -filter {name =~ */dma_mem_raddr_m1* && IS_SEQUENTIAL}]
set_false_path -from [get_cells  -hier -filter {name =~ */axi_mem_last_read_toggle* && IS_SEQUENTIAL}] \
               -to   [get_cells  -hier -filter {name =~ */dma_mem_last_read_toggle_m_* && IS_SEQUENTIAL}]

# DAC clk to DMA clk
set_false_path -from [get_cells  -hier -filter {name =~ */dac_mem_raddr_g* && IS_SEQUENTIAL}] \
               -to   [get_cells  -hier -filter {name =~ */dma_mem_raddr_m1_* && IS_SEQUENTIAL}]
set_false_path -to   [get_cells  -hier -filter {name =~ */dma_rst_m1_reg && IS_SEQUENTIAL}]


# DMA clk to AXI clk
set_false_path -from [get_cells  -hier -filter {name =~ */dma_last_beats* && IS_SEQUENTIAL}] \
               -to   [get_cells  -hier -filter {name =~ */axi_dma_last_beats_m1* && IS_SEQUENTIAL}]
set_false_path -from [get_cells  -hier -filter {name =~ */dma_mem_waddr_g* && IS_SEQUENTIAL}] \
               -to   [get_cells  -hier -filter {name =~ */axi_mem_waddr_m1* && IS_SEQUENTIAL}]
#ignore timing only on the data, the synchronous reset of the FF is connected to the same clock domain
set_false_path -through [get_pins  -hier -filter {name =~ */axi_xfer_req_m_reg[0]/D}]

# DAC clk to AXI clk
set_false_path -from [get_cells  -hier -filter {name =~ */dac_mem_raddr_g* && IS_SEQUENTIAL}] \
               -to   [get_cells  -hier -filter {name =~ */axi_mem_raddr_m1* && IS_SEQUENTIAL}]

# DMA clk to DAC clk
set_false_path -from [get_cells  -hier -filter {name =~ */dma_mem_waddr_g* && IS_SEQUENTIAL}] \
               -to   [get_cells  -hier -filter {name =~ */dac_mem_waddr_m1* && IS_SEQUENTIAL}]
set_false_path -from [get_cells  -hier -filter {name =~ */dma_last_beats* && IS_SEQUENTIAL}] \
               -to   [get_cells  -hier -filter {name =~ */dac_last_beats_m* && IS_SEQUENTIAL}]
#ignore timing only on the data, the synchronous reset of the FF is connected to the same clock domain
set_false_path -through [get_pins  -hier -filter {name =~ */dac_xfer_out_m1_reg*/D}]

# AXI clk to DAC clk
set_false_path -from [get_cells  -hier -filter {name =~ */axi_mem_laddr* && IS_SEQUENTIAL}] \
               -to   [get_cells  -hier -filter {name =~ */dac_mem_laddr* && IS_SEQUENTIAL}]
set_false_path -from [get_cells  -hier -filter {name =~ */axi_mem_laddr_toggle* && IS_SEQUENTIAL}] \
               -to   [get_cells  -hier -filter {name =~ */dac_mem_laddr_toggle_m* && IS_SEQUENTIAL}]
set_false_path -from [get_cells  -hier -filter {name =~ */axi_mem_waddr_g* && IS_SEQUENTIAL}] \
               -to   [get_cells  -hier -filter {name =~ */dac_mem_waddr_m1* && IS_SEQUENTIAL}]
#ignore timing only on the data, the synchronous reset of the FF is connected to the same clock domain
set_false_path -through [get_pins  -hier -filter {name =~ */dac_xfer_req_m_reg[0]/D}]

