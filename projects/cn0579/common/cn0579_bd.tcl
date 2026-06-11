###############################################################################
## Copyright (C) 2023-2024 Analog Devices, Inc. All rights reserved.
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

# ad7768-4 interface

create_bd_port -dir I clk_in
create_bd_port -dir I ready_in
create_bd_port -dir I -from 7 -to 0 data_in

# adc(cn0579-dma)

ad_ip_instance axi_dmac cn0579_dma
ad_ip_parameter cn0579_dma CONFIG.DMA_TYPE_SRC 2
ad_ip_parameter cn0579_dma CONFIG.DMA_TYPE_DEST 0
ad_ip_parameter cn0579_dma CONFIG.CYCLIC 0
ad_ip_parameter cn0579_dma CONFIG.SYNC_TRANSFER_START 1
ad_ip_parameter cn0579_dma CONFIG.AXI_SLICE_SRC 0
ad_ip_parameter cn0579_dma CONFIG.AXI_SLICE_DEST 0
ad_ip_parameter cn0579_dma CONFIG.DMA_2D_TRANSFER 0
ad_ip_parameter cn0579_dma CONFIG.DMA_DATA_WIDTH_SRC 128
ad_ip_parameter cn0579_dma CONFIG.DMA_DATA_WIDTH_DEST 64

# axi_ad77684

ad_ip_instance axi_ad7768 axi_ad77684_adc
ad_ip_parameter axi_ad77684_adc CONFIG.NUM_CHANNELS 4

# adc-path channel pack

ad_ip_instance util_cpack2 cn0579_adc_pack
ad_ip_parameter cn0579_adc_pack CONFIG.NUM_OF_CHANNELS 4
ad_ip_parameter cn0579_adc_pack CONFIG.SAMPLE_DATA_WIDTH 32

# connections

for {set i 0} {$i < 4} {incr i} {
  ad_connect axi_ad77684_adc/adc_enable_$i  cn0579_adc_pack/enable_$i
  ad_connect axi_ad77684_adc/adc_data_$i    cn0579_adc_pack/fifo_wr_data_$i
}

ad_connect axi_ad77684_adc/s_axi_aclk          sys_ps7/FCLK_CLK0 
ad_connect axi_ad77684_adc/clk_in              clk_in
ad_connect axi_ad77684_adc/ready_in            ready_in
ad_connect axi_ad77684_adc/data_in             data_in
ad_connect axi_ad77684_adc/adc_valid           cn0579_adc_pack/fifo_wr_en
ad_connect axi_ad77684_adc/adc_clk             cn0579_adc_pack/clk
ad_connect axi_ad77684_adc/adc_reset           cn0579_adc_pack/reset
ad_connect axi_ad77684_adc/adc_dovf            cn0579_adc_pack/fifo_wr_overflow 

ad_connect  cn0579_dma/m_dest_axi_aresetn       sys_cpu_resetn                   
ad_connect  cn0579_dma/fifo_wr_clk              axi_ad77684_adc/adc_clk                
ad_connect  cn0579_dma/fifo_wr                  cn0579_adc_pack/packed_fifo_wr   
ad_connect  cn0579_dma/sync                     cn0579_adc_pack/packed_sync

# interrupts

ad_cpu_interrupt "ps-12" "mb-12"  cn0579_dma/irq

# cpu / memory interconnects

ad_cpu_interconnect 0x44a00000 axi_ad77684_adc 
ad_cpu_interconnect 0x44a30000 cn0579_dma

ad_mem_hp1_interconnect $sys_cpu_clk sys_ps7/S_AXI_HP1
ad_mem_hp1_interconnect $sys_cpu_clk cn0579_dma/m_dest_axi
