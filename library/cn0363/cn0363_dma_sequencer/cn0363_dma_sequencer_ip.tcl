###############################################################################
## Copyright (C) 2015-2024 Analog Devices, Inc. All rights reserved.
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

source ../../../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_xilinx.tcl

adi_ip_create cn0363_dma_sequencer
adi_ip_files cn0363_dma_sequencer [list \
	"cn0363_dma_sequencer.v"
]

adi_ip_properties_lite cn0363_dma_sequencer

adi_add_bus "phase" "slave" \
	"xilinx.com:interface:axis_rtl:1.0" \
	"xilinx.com:interface:axis:1.0" \
	{
		{"phase_valid" "TVALID"} \
		{"phase_ready" "TREADY"} \
		{"phase" "TDATA"} \
	}

adi_add_bus "data" "slave" \
	"xilinx.com:interface:axis_rtl:1.0" \
	"xilinx.com:interface:axis:1.0" \
	{
		{"data_valid" "TVALID"} \
		{"data_ready" "TREADY"} \
		{"data" "TDATA"} \
	}

adi_add_bus "data_filtered" "slave" \
	"xilinx.com:interface:axis_rtl:1.0" \
	"xilinx.com:interface:axis:1.0" \
	{
		{"data_filtered_valid" "TVALID"} \
		{"data_filtered_ready" "TREADY"} \
		{"data_filtered" "TDATA"} \
	}

adi_add_bus "i_q" "slave" \
	"xilinx.com:interface:axis_rtl:1.0" \
	"xilinx.com:interface:axis:1.0" \
	{
		{"i_q_valid" "TVALID"} \
		{"i_q_ready" "TREADY"} \
		{"i_q" "TDATA"} \
	}

adi_add_bus "i_q_filtered" "slave" \
	"xilinx.com:interface:axis_rtl:1.0" \
	"xilinx.com:interface:axis:1.0" \
	{
		{"i_q_filtered_valid" "TVALID"} \
		{"i_q_filtered_ready" "TREADY"} \
		{"i_q_filtered" "TDATA"} \
	}


adi_add_bus "dma_wr" "master" \
	"analog.com:interface:fifo_wr_rtl:1.0" \
	"analog.com:interface:fifo_wr:1.0" \
	{
		{"dma_wr_en" "EN"} \
		{"dma_wr_data" "DATA"} \
		{"dma_wr_overflow" "OVERFLOW"} \
		{"dma_wr_xfer_req" "XFER_REQ"} \
	}


adi_add_bus_clock "clk" "phase:data:data_filtered:i_q:i_q_filtered:dma_wr" "processing_resetn"

ipx::save_core [ipx::current_core]
