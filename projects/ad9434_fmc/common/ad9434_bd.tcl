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

# ad9434 interface
create_bd_port -dir I adc_clk_p
create_bd_port -dir I adc_clk_n
create_bd_port -dir I -from 11 -to 0 adc_data_p
create_bd_port -dir I -from 11 -to 0 adc_data_n
create_bd_port -dir I adc_or_p
create_bd_port -dir I adc_or_n

# ad9434

ad_ip_instance axi_ad9434 axi_ad9434

# dma for ad9434

ad_ip_instance axi_dmac axi_ad9434_dma
ad_ip_parameter axi_ad9434_dma CONFIG.DMA_TYPE_SRC 2
ad_ip_parameter axi_ad9434_dma CONFIG.DMA_TYPE_DEST 0
ad_ip_parameter axi_ad9434_dma CONFIG.CYCLIC 0
ad_ip_parameter axi_ad9434_dma CONFIG.SYNC_TRANSFER_START 0
ad_ip_parameter axi_ad9434_dma CONFIG.AXI_SLICE_SRC 0
ad_ip_parameter axi_ad9434_dma CONFIG.AXI_SLICE_DEST 0
ad_ip_parameter axi_ad9434_dma CONFIG.DMA_2D_TRANSFER 0
ad_ip_parameter axi_ad9434_dma CONFIG.DMA_DATA_WIDTH_SRC 64

# ad9434 connections

ad_connect  $sys_iodelay_clk axi_ad9434/delay_clk
ad_connect  axi_ad9434/adc_clk axi_ad9434_dma/fifo_wr_clk

ad_connect  adc_clk_p  axi_ad9434/adc_clk_in_p
ad_connect  adc_clk_n  axi_ad9434/adc_clk_in_n
ad_connect  adc_data_p axi_ad9434/adc_data_in_p
ad_connect  adc_data_n axi_ad9434/adc_data_in_n
ad_connect  adc_or_p   axi_ad9434/adc_or_in_p
ad_connect  adc_or_n   axi_ad9434/adc_or_in_n

ad_connect  axi_ad9434/adc_valid axi_ad9434_dma/fifo_wr_en
ad_connect  axi_ad9434/adc_data  axi_ad9434_dma/fifo_wr_din
ad_connect  axi_ad9434/adc_dovf  axi_ad9434_dma/fifo_wr_overflow

# interconnect

ad_cpu_interconnect 0x44A00000  axi_ad9434
ad_cpu_interconnect 0x44A30000  axi_ad9434_dma

# memory inteconnect

ad_mem_hp1_interconnect $sys_dma_clk sys_ps7/S_AXI_HP1
ad_mem_hp1_interconnect $sys_dma_clk axi_ad9434_dma/m_dest_axi
ad_connect $sys_dma_resetn axi_ad9434_dma/m_dest_axi_aresetn

# interrupts

ad_cpu_interrupt ps-13 mb-12 axi_ad9434_dma/irq

