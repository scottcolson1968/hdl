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

# system level parameter

set BUFMRCE_EN $ad_project_params(BUFMRCE_EN)
puts "build parameters: BUFMRCE_EN: $BUFMRCE_EN"

# ada4355 interface

create_bd_port -dir I dco_p
create_bd_port -dir I dco_n
create_bd_port -dir I d0a_p
create_bd_port -dir I d0a_n
create_bd_port -dir I d1a_p
create_bd_port -dir I d1a_n
create_bd_port -dir I sync_n
create_bd_port -dir I frame_p
create_bd_port -dir I frame_n

# axi_ada4355

ad_ip_instance axi_ada4355 axi_ada4355_adc
ad_ip_parameter axi_ada4355_adc CONFIG.BUFMRCE_EN $BUFMRCE_EN

# dma for rx data

ad_ip_instance axi_dmac axi_ada4355_dma
ad_ip_parameter axi_ada4355_dma CONFIG.DMA_TYPE_SRC 2
ad_ip_parameter axi_ada4355_dma CONFIG.DMA_TYPE_DEST 0
ad_ip_parameter axi_ada4355_dma CONFIG.CYCLIC 0
ad_ip_parameter axi_ada4355_dma CONFIG.SYNC_TRANSFER_START 0
ad_ip_parameter axi_ada4355_dma CONFIG.AXI_SLICE_SRC 1
ad_ip_parameter axi_ada4355_dma CONFIG.AXI_SLICE_DEST 0
ad_ip_parameter axi_ada4355_dma CONFIG.DMA_2D_TRANSFER 0
ad_ip_parameter axi_ada4355_dma CONFIG.DMA_DATA_WIDTH_SRC 16
ad_ip_parameter axi_ada4355_dma CONFIG.DMA_DATA_WIDTH_DEST 64

# connect interface to axi_ad4355_adc

ad_connect dco_p                axi_ada4355_adc/dco_p
ad_connect dco_n                axi_ada4355_adc/dco_n
ad_connect d0a_p                axi_ada4355_adc/d0a_p
ad_connect d0a_n                axi_ada4355_adc/d0a_n
ad_connect d1a_p                axi_ada4355_adc/d1a_p
ad_connect d1a_n                axi_ada4355_adc/d1a_n
ad_connect sync_n               axi_ada4355_adc/sync_n
ad_connect frame_p              axi_ada4355_adc/fco_p
ad_connect frame_n              axi_ada4355_adc/fco_n
ad_connect $sys_iodelay_clk     axi_ada4355_adc/delay_clk

# connect datapath

ad_connect axi_ada4355_adc/adc_data  axi_ada4355_dma/fifo_wr_din
ad_connect axi_ada4355_adc/adc_valid axi_ada4355_dma/fifo_wr_en
ad_connect axi_ada4355_adc/adc_dovf  axi_ada4355_dma/fifo_wr_overflow

# system runs on if.v's received clock

ad_connect axi_ada4355_adc/adc_clk axi_ada4355_dma/fifo_wr_clk

ad_connect $sys_cpu_resetn axi_ada4355_dma/m_dest_axi_aresetn

ad_cpu_interconnect 0x44A00000 axi_ada4355_adc
ad_cpu_interconnect 0x44A30000 axi_ada4355_dma

ad_mem_hp1_interconnect $sys_cpu_clk sys_ps7/S_AXI_HP1
ad_mem_hp1_interconnect $sys_cpu_clk axi_ada4355_dma/m_dest_axi

ad_cpu_interrupt ps-13 mb-12 axi_ada4355_dma/irq
