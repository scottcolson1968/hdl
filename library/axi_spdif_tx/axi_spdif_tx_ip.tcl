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

# ip
source ../../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_xilinx.tcl

adi_ip_create axi_spdif_tx
adi_ip_files axi_spdif_tx [list \
  "$ad_hdl_dir/library/common/axi_ctrlif.vhd" \
  "$ad_hdl_dir/library/common/axi_streaming_dma_tx_fifo.vhd" \
  "$ad_hdl_dir/library/common/pl330_dma_fifo.vhd" \
  "$ad_hdl_dir/library/common/dma_fifo.vhd" \
  "tx_package.vhd" \
  "tx_encoder.vhd" \
  "axi_spdif_tx.vhd" \
  "axi_spdif_tx_constr.xdc" ]

adi_ip_properties axi_spdif_tx
adi_ip_infer_streaming_interfaces axi_spdif_tx

adi_add_bus "dma_ack" "slave" \
	"xilinx.com:interface:axis_rtl:1.0" \
	"xilinx.com:interface:axis:1.0" \
	[list {"dma_req_davalid" "TVALID"} \
		{"dma_req_daready" "TREADY"} \
		{"dma_req_datype" "TUSER"} ]
adi_add_bus "dma_req" "master" \
	"xilinx.com:interface:axis_rtl:1.0" \
	"xilinx.com:interface:axis:1.0" \
	[list {"dma_req_drvalid" "TVALID"} \
		{"dma_req_drready" "TREADY"} \
		{"dma_req_drtype" "TUSER"} \
		{"dma_req_drlast" "TLAST"} ]

# Clock and reset are for both dma_req and dma_ack
adi_add_bus_clock "dma_req_aclk" "dma_req:dma_ack" "dma_req_rstn"

adi_set_bus_dependency "s_axis" "s_axis" \
	"(spirit:decode(id('MODELPARAM_VALUE.DMA_TYPE')) = 0)"

adi_set_bus_dependency "dma_ack" "dma_req_da" \
	"(spirit:decode(id('MODELPARAM_VALUE.DMA_TYPE')) = 1)"
adi_set_bus_dependency "dma_req" "dma_req_dr" \
	"(spirit:decode(id('MODELPARAM_VALUE.DMA_TYPE')) = 1)"
adi_set_ports_dependency "dma_req_aclk" \
	"(spirit:decode(id('MODELPARAM_VALUE.DMA_TYPE')) = 1)"
adi_set_ports_dependency "dma_req_rstn" \
	"(spirit:decode(id('MODELPARAM_VALUE.DMA_TYPE')) = 1)"

ipx::save_core [ipx::current_core]

