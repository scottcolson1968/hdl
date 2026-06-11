###############################################################################
## Copyright (C) 2019-2025 Analog Devices, Inc. All rights reserved.
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

create_bd_port -dir O adc_clk
create_bd_port -dir I adc_data

# ADC's DMA

ad_ip_instance axi_dmac axi_ad7405_dma
ad_ip_parameter axi_ad7405_dma CONFIG.DMA_TYPE_SRC 2
ad_ip_parameter axi_ad7405_dma CONFIG.DMA_TYPE_DEST 0
ad_ip_parameter axi_ad7405_dma CONFIG.CYCLIC 0
ad_ip_parameter axi_ad7405_dma CONFIG.SYNC_TRANSFER_START 1
ad_ip_parameter axi_ad7405_dma CONFIG.AXI_SLICE_SRC 0
ad_ip_parameter axi_ad7405_dma CONFIG.AXI_SLICE_DEST 1
ad_ip_parameter axi_ad7405_dma CONFIG.DMA_2D_TRANSFER 0
ad_ip_parameter axi_ad7405_dma CONFIG.DMA_DATA_WIDTH_SRC 16
ad_ip_parameter axi_ad7405_dma CONFIG.DMA_DATA_WIDTH_DEST 64

# MCLK generation 40 MHz

ad_ip_instance axi_clkgen axi_adc_clkgen
ad_ip_parameter axi_adc_clkgen CONFIG.VCO_DIV 1
ad_ip_parameter axi_adc_clkgen CONFIG.VCO_MUL 10
ad_ip_parameter axi_adc_clkgen CONFIG.CLK0_DIV 25

ad_ip_instance axi_ad7405 axi_ad7405

ad_connect adc_clk axi_adc_clkgen/clk_0
ad_connect sys_cpu_clk axi_adc_clkgen/clk
ad_connect axi_ad7405/clk_in axi_adc_clkgen/clk_0
ad_connect axi_ad7405_dma/fifo_wr_clk axi_adc_clkgen/clk_0

ad_connect adc_data axi_ad7405/adc_data_in
ad_connect axi_ad7405/adc_data_out axi_ad7405_dma/fifo_wr_din
ad_connect axi_ad7405/adc_data_en axi_ad7405_dma/fifo_wr_en

# interconnect

ad_cpu_interconnect 0x44a00000 axi_ad7405
ad_cpu_interconnect 0x44a30000 axi_ad7405_dma
ad_cpu_interconnect 0x44a40000 axi_adc_clkgen

# memory interconnect

ad_mem_hp2_interconnect sys_cpu_clk sys_ps7/S_AXI_HP2
ad_mem_hp2_interconnect sys_cpu_clk axi_ad7405_dma/m_dest_axi

# interrupt

ad_cpu_interrupt "ps-13" "mb-13" axi_ad7405_dma/irq
