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

set_property ASYNC_REG TRUE [get_cells -hierarchical -filter {name =~ *dac_waddr_m*}] \
  [get_cells -hierarchical -filter {name =~ *dac_lastaddr_m*}] \
  [get_cells -hierarchical -filter {name =~ *dac_xfer_out_*}] \
  [get_cells -hierarchical -filter {name =~ *dma_bypass*}] \
  [get_cells -hierarchical -filter {name =~ *dac_bypass*}] \
  [get_cells -hierarchical -filter {name =~ *dac_xfer_req_m*}]

set_false_path -from [get_cells -hierarchical -filter {name =~ *dma_waddr_g* && IS_SEQUENTIAL}] \
               -to [get_cells -hierarchical -filter {name =~ *dac_waddr_m1* && IS_SEQUENTIAL}]
set_false_path -from [get_cells -hierarchical -filter {name =~ *dma_lastaddr_g* && IS_SEQUENTIAL}] \
               -to [get_cells -hierarchical -filter {name =~ *dac_lastaddr_m1* && IS_SEQUENTIAL}]
set_false_path -from [get_cells -hierarchical -filter {name =~ *dma_xfer_out_fifo* && IS_SEQUENTIAL}] \
               -to [get_cells -hierarchical -filter {name =~ *dac_xfer_out_fifo_m1* && IS_SEQUENTIAL}]
set_false_path -to [get_cells -hierarchical -filter {name =~ *dac_bypass_m1* && IS_SEQUENTIAL}]
set_false_path -to [get_cells -hierarchical -filter {name =~ *dma_bypass_m1* && IS_SEQUENTIAL}]

# util_dacfifo_bypass CDC false-paths

set_property ASYNC_REG TRUE [get_cells -hierarchical -filter {name =~ *dac_mem_*_m*}] \
  [get_cells -hierarchical -filter {name =~ *dma_mem_*_m*}] \
  [get_cells -hierarchical -filter {name =~ *dma_rst_m1*}] \

set_false_path -from [get_cells  -hierarchical -filter {name =~ */dma_mem_waddr_g* && IS_SEQUENTIAL}] \
               -to   [get_cells  -hierarchical -filter {name =~ */dac_mem_waddr_m1* && IS_SEQUENTIAL}]
set_false_path -from [get_cells  -hierarchical -filter {name =~ */dac_mem_raddr_g* && IS_SEQUENTIAL}] \
               -to   [get_cells  -hierarchical -filter {name =~ */dma_mem_raddr_m1* && IS_SEQUENTIAL}]
set_false_path -to   [get_cells  -hierarchical -filter {name =~ */dma_rst_m1_reg && IS_SEQUENTIAL}]
set_false_path -to   [get_cells  -hierarchical -filter {name =~ */dac_xfer_req_m1_reg && IS_SEQUENTIAL}]
set_false_path -from [get_cells  -hierarchical -filter {name =~ */dma_xfer_req* && IS_SEQUENTIAL}] \
               -to   [get_cells  -hierarchical -filter {name =~ */dac_mem_waddr_m1* && IS_SEQUENTIAL}]

