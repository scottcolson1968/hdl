###############################################################################
## Copyright (C) 2017-2026 Analog Devices, Inc. All rights reserved.
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

create_bd_intf_port -mode Master -vlnv analog.com:interface:spi_engine_rtl:1.0 adc_spi

create_bd_port -dir I adc_data_ready

# create a SPI Engine architecture for ADC

source $ad_hdl_dir/library/spi_engine/scripts/spi_engine.tcl

set hier_spi_engine  spi_ad77681
set data_width       32
set async_spi_clk    1
set offload_en       1
set num_cs           1
set num_sdi          1
set num_sdo          1
set sdi_delay        1
set echo_sclk        0

spi_engine_create $hier_spi_engine $data_width $async_spi_clk $offload_en $num_cs $num_sdi $num_sdo $sdi_delay $echo_sclk

ad_ip_parameter $hier_spi_engine/${hier_spi_engine}_offload CONFIG.ASYNC_TRIG 1

ad_ip_instance axi_clkgen spi_clkgen
ad_ip_parameter spi_clkgen CONFIG.CLK0_DIV 5
ad_ip_parameter spi_clkgen CONFIG.VCO_DIV 1
ad_ip_parameter spi_clkgen CONFIG.VCO_MUL 8

# dma for the ADC

ad_ip_instance axi_dmac axi_ad77681_dma
ad_ip_parameter axi_ad77681_dma CONFIG.DMA_TYPE_SRC 1
ad_ip_parameter axi_ad77681_dma CONFIG.DMA_TYPE_DEST 0
ad_ip_parameter axi_ad77681_dma CONFIG.CYCLIC 0
ad_ip_parameter axi_ad77681_dma CONFIG.SYNC_TRANSFER_START 0
ad_ip_parameter axi_ad77681_dma CONFIG.AXI_SLICE_SRC 0
ad_ip_parameter axi_ad77681_dma CONFIG.AXI_SLICE_DEST 1
ad_ip_parameter axi_ad77681_dma CONFIG.DMA_2D_TRANSFER 0
ad_ip_parameter axi_ad77681_dma CONFIG.DMA_DATA_WIDTH_SRC 32
ad_ip_parameter axi_ad77681_dma CONFIG.DMA_DATA_WIDTH_DEST 64

ad_connect $sys_cpu_clk spi_clkgen/clk
ad_connect spi_clk spi_clkgen/clk_0
ad_connect adc_data_ready $hier_spi_engine/trigger
ad_connect axi_ad77681_dma/s_axis $hier_spi_engine/M_AXIS_SAMPLE
ad_connect $hier_spi_engine/m_spi adc_spi
ad_connect $sys_cpu_clk $hier_spi_engine/clk
ad_connect spi_clk $hier_spi_engine/spi_clk
ad_connect spi_clk axi_ad77681_dma/s_axis_aclk
ad_connect sys_cpu_resetn $hier_spi_engine/resetn
ad_connect sys_cpu_resetn axi_ad77681_dma/m_dest_axi_aresetn

# AXI address definitions

ad_cpu_interconnect 0x44a00000 $hier_spi_engine/${hier_spi_engine}_axi_regmap
ad_cpu_interconnect 0x44a30000 axi_ad77681_dma
ad_cpu_interconnect 0x44a70000 spi_clkgen

# interrupts

ad_cpu_interrupt "ps-13" "mb-13" axi_ad77681_dma/irq
ad_cpu_interrupt "ps-12" "mb-12" $hier_spi_engine/irq

# memory interconnects

ad_mem_hp2_interconnect sys_cpu_clk sys_ps7/S_AXI_HP0
ad_mem_hp2_interconnect sys_cpu_clk axi_ad77681_dma/m_dest_axi

