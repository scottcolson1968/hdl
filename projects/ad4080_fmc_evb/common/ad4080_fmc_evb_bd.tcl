###############################################################################
## Copyright (C) 2024-2025 Analog Devices, Inc. All rights reserved.
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

set ADC_N_BITS $ad_project_params(ADC_N_BITS)
if {$ADC_N_BITS <= 16} {
    set DMA_DATA_WIDTH_SRC 16
} else {
    set DMA_DATA_WIDTH_SRC 32
}

# ad4080 interface

create_bd_port -dir I dco_p
create_bd_port -dir I dco_n
create_bd_port -dir I da_p
create_bd_port -dir I da_n
create_bd_port -dir I db_p
create_bd_port -dir I db_n
create_bd_port -dir I sync_n
create_bd_port -dir I cnv_in_p
create_bd_port -dir I cnv_in_n
create_bd_port -dir I filter_data_ready_n
create_bd_port -dir I fpga_ref_clk
create_bd_port -dir I fpga_100_clk

# ad4080_clock_monitor

ad_ip_instance axi_clock_monitor ad4080_clock_monitor
ad_ip_parameter ad4080_clock_monitor CONFIG.NUM_OF_CLOCKS 2
ad_ip_parameter ad4080_clock_monitor CONFIG.DIV_RATE 4

ad_connect fpga_ref_clk  ad4080_clock_monitor/clock_0
ad_connect fpga_100_clk  ad4080_clock_monitor/clock_1

# axi_ad408x

ad_ip_instance axi_ad408x axi_ad4080_adc
ad_ip_parameter axi_ad4080_adc CONFIG.ADC_N_BITS $ADC_N_BITS

# dma for rx data

ad_ip_instance axi_dmac axi_ad4080_dma
ad_ip_parameter axi_ad4080_dma CONFIG.DMA_TYPE_SRC 2
ad_ip_parameter axi_ad4080_dma CONFIG.DMA_TYPE_DEST 0
ad_ip_parameter axi_ad4080_dma CONFIG.CYCLIC 0
ad_ip_parameter axi_ad4080_dma CONFIG.SYNC_TRANSFER_START 0
ad_ip_parameter axi_ad4080_dma CONFIG.AXI_SLICE_SRC 1
ad_ip_parameter axi_ad4080_dma CONFIG.AXI_SLICE_DEST 0
ad_ip_parameter axi_ad4080_dma CONFIG.DMA_2D_TRANSFER 0
ad_ip_parameter axi_ad4080_dma CONFIG.DMA_DATA_WIDTH_SRC $DMA_DATA_WIDTH_SRC
ad_ip_parameter axi_ad4080_dma CONFIG.DMA_DATA_WIDTH_DEST 64

# connect interface to axi_ad4080_adc

ad_connect dco_p                axi_ad4080_adc/dclk_in_p
ad_connect dco_n                axi_ad4080_adc/dclk_in_n
ad_connect da_p                 axi_ad4080_adc/data_a_in_p
ad_connect da_n                 axi_ad4080_adc/data_a_in_n
ad_connect db_p                 axi_ad4080_adc/data_b_in_p
ad_connect db_n                 axi_ad4080_adc/data_b_in_n
ad_connect sync_n               axi_ad4080_adc/sync_n
ad_connect cnv_in_p             axi_ad4080_adc/cnv_in_p
ad_connect cnv_in_n             axi_ad4080_adc/cnv_in_n
ad_connect filter_data_ready_n  axi_ad4080_adc/filter_data_ready_n
ad_connect $sys_iodelay_clk     axi_ad4080_adc/delay_clk

# connect datapath

ad_connect axi_ad4080_adc/adc_data  axi_ad4080_dma/fifo_wr_din
ad_connect axi_ad4080_adc/adc_valid axi_ad4080_dma/fifo_wr_en
ad_connect axi_ad4080_adc/adc_dovf  axi_ad4080_dma/fifo_wr_overflow

# system runs on phy's received clock

ad_connect axi_ad4080_adc/adc_clk axi_ad4080_dma/fifo_wr_clk

ad_connect $sys_cpu_resetn axi_ad4080_dma/m_dest_axi_aresetn

ad_cpu_interconnect 0x44A00000 axi_ad4080_adc
ad_cpu_interconnect 0x44A30000 axi_ad4080_dma
ad_cpu_interconnect 0x44A40000 ad4080_clock_monitor

ad_mem_hp1_interconnect $sys_cpu_clk sys_ps7/S_AXI_HP1
ad_mem_hp1_interconnect $sys_cpu_clk axi_ad4080_dma/m_dest_axi

ad_cpu_interrupt ps-13 mb-12 axi_ad4080_dma/irq
