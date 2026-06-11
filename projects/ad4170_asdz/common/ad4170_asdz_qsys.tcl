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

# receive dma
set_instance_parameter_value sys_hps {F2SDRAM_Width} {128 64}

add_instance axi_dmac_0 axi_dmac
set_instance_parameter_value axi_dmac_0 {DMA_TYPE_SRC} {1}
set_instance_parameter_value axi_dmac_0 {DMA_TYPE_DEST} {0}
set_instance_parameter_value axi_dmac_0 {CYCLIC} {0}
set_instance_parameter_value axi_dmac_0 {DMA_DATA_WIDTH_SRC} {32}
set_instance_parameter_value axi_dmac_0 {DMA_DATA_WIDTH_DEST} {64}

# spi engine
source $ad_hdl_dir/library/spi_engine/scripts/spi_engine.tcl

set spi_engine_hier  spi_ad4170
set axi_clk          sys_clk.clk
set axi_reset        sys_clk.clk_reset
set spi_clk          sys_dma_clk.clk
set data_width       32
set async_spi_clk    1
set offload_en       1
set num_cs           1
set num_sdi          1
set num_sdo          1
set sdi_delay        0
set echo_sclk        0
set sdo_streaming    0

spi_engine_create $spi_engine_hier $axi_clk $axi_reset $spi_clk $data_width $async_spi_clk $offload_en $num_cs $num_sdi $num_sdo $sdi_delay $echo_sclk $sdo_streaming
set_instance_parameter_value ${spi_engine_hier}_offload {ASYNC_TRIG} {1}

# exported interface

add_interface ad4170_spi_sclk       clock source
add_interface ad4170_spi_cs         conduit end
add_interface ad4170_spi_sdi        conduit end
add_interface ad4170_spi_sdo        conduit end
add_interface ad4170_spi_trigger    conduit end

set_interface_property ad4170_spi_cs      EXPORT_OF ${spi_engine_hier}_execution.if_cs
set_interface_property ad4170_spi_sclk    EXPORT_OF ${spi_engine_hier}_execution.if_sclk
set_interface_property ad4170_spi_sdi     EXPORT_OF ${spi_engine_hier}_execution.if_sdi
set_interface_property ad4170_spi_sdo     EXPORT_OF ${spi_engine_hier}_execution.if_sdo
set_interface_property ad4170_spi_trigger EXPORT_OF ${spi_engine_hier}_offload.if_trigger

# clocks

add_connection sys_clk.clk axi_dmac_0.s_axi_clock

add_connection sys_dma_clk.clk axi_dmac_0.if_s_axis_aclk
add_connection sys_dma_clk.clk axi_dmac_0.m_dest_axi_clock

# resets

add_connection sys_clk.clk_reset axi_dmac_0.s_axi_reset

add_connection sys_dma_clk.clk_reset axi_dmac_0.m_dest_axi_reset

# interfaces
add_connection ${spi_engine_hier}_offload.offload_sdi axi_dmac_0.s_axis

# cpu interconnects

ad_cpu_interconnect 0x00020000 axi_dmac_0.s_axi
ad_cpu_interconnect 0x00030000 ${spi_engine_hier}_axi_regmap.s_axi

# dma interconnect
ad_dma_interconnect axi_dmac_0.m_dest_axi

#interrupts

ad_cpu_interrupt 4 axi_dmac_0.interrupt_sender
ad_cpu_interrupt 5 ${spi_engine_hier}_axi_regmap.interrupt_sender
