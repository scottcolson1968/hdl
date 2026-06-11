###############################################################################
## Copyright (C) 2024-2026 Analog Devices, Inc. All rights reserved.
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

# bd ports

create_bd_intf_port -mode Master -vlnv analog.com:interface:spi_engine_rtl:1.0 ad57xx_spi

# create a SPI Engine architecture for the DAC

source $ad_hdl_dir/library/spi_engine/scripts/spi_engine.tcl

set hier_spi_engine  spi_ad57xx
set data_width       32
set async_spi_clk    1
set offload_en       1
set num_cs           1
set num_sdi          1
set num_sdo          1
set sdi_delay        0
set echo_sclk        0
set sdo_streaming    1

spi_engine_create $hier_spi_engine $data_width $async_spi_clk $offload_en $num_cs $num_sdi $num_sdo $sdi_delay $echo_sclk $sdo_streaming

# clkgen

ad_ip_instance axi_clkgen axi_ad57xx_clkgen;
ad_ip_parameter axi_ad57xx_clkgen CONFIG.VCO_DIV 1
ad_ip_parameter axi_ad57xx_clkgen CONFIG.VCO_MUL 7
ad_ip_parameter axi_ad57xx_clkgen CONFIG.CLK0_DIV 5

# dma to send sample data

ad_ip_instance axi_dmac ad57xx_dma
ad_ip_parameter ad57xx_dma CONFIG.DMA_TYPE_SRC 0
ad_ip_parameter ad57xx_dma CONFIG.DMA_TYPE_DEST 1
ad_ip_parameter ad57xx_dma CONFIG.CYCLIC 0
ad_ip_parameter ad57xx_dma CONFIG.SYNC_TRANSFER_START 0
ad_ip_parameter ad57xx_dma CONFIG.DMA_2D_TRANSFER 0
ad_ip_parameter ad57xx_dma CONFIG.DMA_DATA_WIDTH_SRC 64
ad_ip_parameter ad57xx_dma CONFIG.DMA_DATA_WIDTH_DEST $data_width

# trigger generator

ad_ip_instance axi_pwm_gen trig_gen
ad_ip_parameter trig_gen CONFIG.N_PWMS 1
ad_ip_parameter trig_gen CONFIG.PULSE_0_PERIOD 98
ad_ip_parameter trig_gen CONFIG.PULSE_0_WIDTH 1

ad_connect trig_gen/ext_clk axi_ad57xx_clkgen/clk_0
ad_connect trig_gen/pwm_0 $hier_spi_engine/trigger

ad_connect  axi_ad57xx_clkgen/clk_0 $hier_spi_engine/spi_clk
ad_connect  $sys_cpu_clk axi_ad57xx_clkgen/clk
ad_connect  $sys_cpu_clk $hier_spi_engine/clk
ad_connect  axi_ad57xx_clkgen/clk_0 ad57xx_dma/m_axis_aclk
ad_connect  sys_cpu_resetn $hier_spi_engine/resetn
ad_connect  sys_cpu_resetn ad57xx_dma/m_src_axi_aresetn

ad_connect  $hier_spi_engine/m_spi ad57xx_spi
ad_connect  ad57xx_dma/m_axis $hier_spi_engine/s_axis_sample

# AXI address definitions

ad_cpu_interconnect 0x44a00000 $hier_spi_engine/${hier_spi_engine}_axi_regmap
ad_cpu_interconnect 0x44a40000 ad57xx_dma
ad_cpu_interconnect 0x44b00000 trig_gen
ad_cpu_interconnect 0x44b10000 axi_ad57xx_clkgen

# interrupts

ad_cpu_interrupt "ps-13" "mb-13" ad57xx_dma/irq
ad_cpu_interrupt "ps-12" "mb-12" $hier_spi_engine/irq

# memory interconnects

ad_mem_hp1_interconnect $sys_cpu_clk sys_ps7/S_AXI_HP1
ad_mem_hp1_interconnect $sys_cpu_clk ad57xx_dma/m_src_axi
