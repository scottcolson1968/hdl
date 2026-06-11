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

package require qsys 14.0
source ../../scripts/adi_env.tcl
source ../scripts/adi_ip_intel.tcl

ad_ip_create util_dacfifo {UTIL DAC FIFO Interface}
ad_ip_files util_dacfifo [list\
  $ad_hdl_dir/library/common/ad_mem.v \
  $ad_hdl_dir/library/common/ad_mem_asym.v \
  $ad_hdl_dir/library/common/ad_b2g.v \
  $ad_hdl_dir/library/common/ad_g2b.v \
  util_dacfifo.v \
  util_dacfifo_bypass.v \
  util_dacfifo_constr.sdc]

# parameters

ad_ip_parameter DEVICE_FAMILY STRING {Arria 10}
ad_ip_parameter ADDRESS_WIDTH INTEGER 6
ad_ip_parameter DATA_WIDTH INTEGER 128

# interfaces

ad_interface clock dma_clk input 1 clk
ad_interface reset dma_rst input 1 if_dma_clk
ad_interface signal dma_xfer_req input 1 xfer_req

add_interface s_axis axi4stream end
set_interface_property s_axis associatedClock if_dma_clk
set_interface_property s_axis associatedReset if_dma_rst
add_interface_port  s_axis  dma_valid      tvalid  Input   1
add_interface_port  s_axis  dma_xfer_last  tlast   Input   1
add_interface_port  s_axis  dma_ready      tready  Output  1
add_interface_port  s_axis  dma_data       tdata   Input   DATA_WIDTH

ad_interface clock dac_clk input 1
ad_interface reset dac_rst input 1 if_dac_clk
ad_interface signal dac_valid input 1 valid
ad_interface signal dac_data output DATA_WIDTH data
ad_interface signal dac_xfer_out output 1 xfer_req
ad_interface signal dac_dunf output 1 unf

ad_interface signal bypass input 1 bypass

