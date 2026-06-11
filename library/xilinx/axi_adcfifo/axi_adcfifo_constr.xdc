###############################################################################
## Copyright (C) 2014-2023 Analog Devices, Inc. All rights reserved.
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
  [get_cells -hier *axi_waddr_m1_reg*] \
  [get_cells -hier *axi_waddr_m2_reg*] \
  [get_cells -hier *adc_xfer_req_m_reg[0]*] \
  [get_cells -hier *axi_xfer_req_m_reg[0]*]

set_false_path -from [get_cells -hier -filter {name =~ *dma_* && IS_SEQUENTIAL}] \
               -to   [get_cells -hier -filter {name =~ *axi_*_m* && IS_SEQUENTIAL}]
set_false_path -from [get_cells -hier -filter {name =~ *axi_* && IS_SEQUENTIAL}] \
               -to   [get_cells -hier -filter {name =~ *dma_*_m* && IS_SEQUENTIAL}]

set_false_path -from [get_cells -hier -filter {name =~ *adc_* && IS_SEQUENTIAL}] \
               -to   [get_cells -hier -filter {name =~ *axi_*_m* && IS_SEQUENTIAL}]
set_false_path -from [get_cells -hier -filter {name =~ *axi_* && IS_SEQUENTIAL}] \
               -to   [get_cells -hier -filter {name =~ *adc_*_m* && IS_SEQUENTIAL}]

set_false_path -from [get_cells -hier -filter {name =~ *d_xfer_* && IS_SEQUENTIAL}] \
               -to   [get_cells -hier -filter {name =~ *up_* && IS_SEQUENTIAL}]
set_false_path -from [get_cells -hier -filter {name =~ *up_xfer_* && IS_SEQUENTIAL}] \
               -to   [get_cells -hier -filter {name =~ *d_xfer_* && IS_SEQUENTIAL}]
set_false_path -from [get_cells -hier -filter {name =~ *adc_rel_waddr* && IS_SEQUENTIAL}] \
               -to   [get_cells -hier -filter {name =~ *axi_rel_waddr* && IS_SEQUENTIAL}]
set_false_path -from [get_cells -hier -filter {name =~ *axi_waddr_rel_reg* && IS_SEQUENTIAL}] \
               -to   [get_cells -hier -filter {name =~ *dma_waddr_rel_reg* && IS_SEQUENTIAL}]
set_false_path -from [get_cells -hier -filter {name =~ *dma_raddr_rel_reg* && IS_SEQUENTIAL}] \
               -to   [get_cells -hier -filter {name =~ *axi_raddr_rel_reg* && IS_SEQUENTIAL}]

set_false_path -to [get_cells -hier -filter {name =~ *adc_xfer_req_m_reg[0]* && IS_SEQUENTIAL}]
set_false_path -to [get_cells -hier -filter {name =~ *axi_xfer_req_m_reg[0]* && IS_SEQUENTIAL}]
