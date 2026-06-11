###############################################################################
## Copyright (C) 2017-2023 Analog Devices, Inc. All rights reserved.
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

# CDC paths

set_false_path  -from [get_registers *avl_dacfifo_rd:i_rd|dac_mem_raddr_g*] \
                -to   [get_registers *avl_dacfifo_rd:i_rd|avl_mem_raddr_m1*]
set_false_path  -from [get_registers *avl_dacfifo_rd:i_rd|avl_mem_waddr_g*] \
                -to   [get_registers *avl_dacfifo_rd:i_rd|dac_mem_waddr_m1*]
set_false_path  -from [get_registers *avl_dacfifo_rd:i_rd|avl_xfer_req_out*] \
                -to   [get_registers *avl_dacfifo_rd:i_rd|dac_avl_xfer_req_m1*]
set_false_path  -from [get_registers *avl_dacfifo_rd:i_rd|avl_mem_laddr_toggle*] \
                -to   [get_registers *avl_dacfifo_rd:i_rd|dac_mem_laddr_toggle_m[0]]
set_false_path  -to   [get_registers *avl_dacfifo_rd:i_rd|dac_mem_laddr*]
set_false_path  -to   [get_registers *avl_dacfifo_rd:i_rd|dac_dma_last_beats_m1*]

set_false_path  -from [get_registers *avl_dacfifo_wr:i_wr|avl_xfer_req_lp*] \
                -to   [get_registers *avl_dacfifo_wr:i_wr|dma_xfer_req_lp_m1*]
set_false_path  -from [get_registers *avl_dacfifo_wr:i_wr|avl_xfer_req_out*] \
                -to   [get_registers *avl_dacfifo_wr:i_wr|dma_avl_xfer_req_out_m1*]
set_false_path  -from [get_registers *avl_dacfifo_wr:i_wr|avl_mem_raddr_g*] \
                -to   [get_registers *avl_dacfifo_wr:i_wr|dma_mem_raddr_m1*]
set_false_path  -from [get_registers *avl_dacfifo_wr:i_wr|dma_xfer_req*] \
                -to   [get_registers *avl_dacfifo_wr:i_wr|avl_dma_xfer_req_m1*]
set_false_path  -from [get_registers *avl_dacfifo_wr:i_wr|dma_mem_waddr_g*] \
                -to   [get_registers *avl_dacfifo_wr:i_wr|avl_mem_waddr_m1*]
set_false_path  -from [get_registers *avl_dacfifo_wr:i_wr|dma_last_beats*] \
                -to   [get_registers *avl_dacfifo_wr:i_wr|avl_dma_last_beats_m1*]

set_false_path  -from [get_registers *util_dacfifo_bypass:i_dacfifo_bypass|dac_mem_raddr_g*] \
                -to   [get_registers *util_dacfifo_bypass:i_dacfifo_bypass|dma_mem_raddr_m1*]

set_false_path  -from [get_registers *util_dacfifo_bypass:i_dacfifo_bypass|dma_mem_waddr_g*] \
                -to   [get_registers *util_dacfifo_bypass:i_dacfifo_bypass|dac_mem_waddr_m1*]
set_false_path  -to   [get_registers *util_dacfifo_bypass:i_dacfifo_bypass|dac_xfer_out_m1*]

set_false_path  -to [get_registers *avl_dacfifo:*avl_dma_xfer_req_m1*]
set_false_path  -to [get_registers *avl_dacfifo:*dac_xfer_out_m1*]
set_false_path  -to [get_registers *avl_dacfifo:*bypass_m1*]

set_false_path  -to [get_registers *util_dacfifo_bypass:i_dacfifo_bypass|dma_rst_m1*]

