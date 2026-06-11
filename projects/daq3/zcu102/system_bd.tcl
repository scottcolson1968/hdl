###############################################################################
## Copyright (C) 2014-2026 Analog Devices, Inc. All rights reserved.
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

source $ad_hdl_dir/projects/common/zcu102/zcu102_system_bd.tcl
source ../common/daq3_bd.tcl
source $ad_hdl_dir/projects/scripts/adi_pd.tcl

#system ID
ad_ip_parameter axi_sysid_0 CONFIG.ROM_ADDR_BITS 9
ad_ip_parameter rom_sys_0 CONFIG.PATH_TO_FILE "$mem_init_sys_file_path/mem_init_sys.txt"
ad_ip_parameter rom_sys_0 CONFIG.ROM_ADDR_BITS 9

set sys_cstring "RX:M=$ad_project_params(RX_JESD_M)\
L=$ad_project_params(RX_JESD_L)\
S=$ad_project_params(RX_JESD_S)\
TX:M=$ad_project_params(TX_JESD_M)\
L=$ad_project_params(TX_JESD_L)\
S=$ad_project_params(TX_JESD_S)"

sysid_gen_sys_init_file $sys_cstring

# configure the CPLL's to support 12.33Gbps
ad_ip_parameter util_daq3_xcvr CONFIG.CPLL_CFG0 0x03fe
ad_ip_parameter util_daq3_xcvr CONFIG.CPLL_CFG1 0x0021
ad_ip_parameter util_daq3_xcvr CONFIG.CPLL_CFG2 0x0203

ad_ip_parameter axi_ad9152_dma CONFIG.FIFO_SIZE 32
ad_ip_parameter axi_ad9152_dma CONFIG.AXI_SLICE_SRC 1
ad_ip_parameter axi_ad9152_dma CONFIG.AXI_SLICE_DEST 1
ad_ip_parameter axi_ad9152_dma CONFIG.CYCLIC 1
ad_ip_parameter axi_ad9152_dma CONFIG.MAX_BYTES_PER_BURST 256

ad_ip_parameter axi_ad9680_dma CONFIG.DMA_TYPE_SRC 2
ad_ip_parameter axi_ad9680_dma CONFIG.DMA_DATA_WIDTH_DEST 128
ad_ip_parameter axi_ad9680_dma CONFIG.FIFO_SIZE 32
ad_ip_parameter axi_ad9680_dma CONFIG.AXI_SLICE_SRC 1
ad_ip_parameter axi_ad9680_dma CONFIG.AXI_SLICE_DEST 1
ad_ip_parameter axi_ad9680_dma CONFIG.MAX_BYTES_PER_BURST 256

ad_ip_instance clk_wiz dma_clk_wiz
ad_ip_parameter dma_clk_wiz CONFIG.PRIMITIVE MMCM
ad_ip_parameter dma_clk_wiz CONFIG.RESET_TYPE ACTIVE_LOW
ad_ip_parameter dma_clk_wiz CONFIG.USE_LOCKED false
ad_ip_parameter dma_clk_wiz CONFIG.CLKOUT1_REQUESTED_OUT_FREQ 332.9
ad_ip_parameter dma_clk_wiz CONFIG.PRIM_SOURCE No_buffer

ad_ip_instance proc_sys_reset sys_dma_rstgen

ad_connect sys_cpu_clk dma_clk_wiz/clk_in1
ad_connect sys_cpu_resetn dma_clk_wiz/resetn

ad_connect sys_dma_clk dma_clk_wiz/clk_out1

ad_connect sys_dma_clk sys_dma_rstgen/slowest_sync_clk
ad_connect sys_cpu_resetn sys_dma_rstgen/ext_reset_in

ad_connect sys_dma_reset sys_dma_rstgen/peripheral_reset
ad_connect sys_dma_resetn sys_dma_rstgen/peripheral_aresetn

ad_connect sys_dma_resetn axi_ad9152_dma/m_src_axi_aresetn
ad_connect util_daq3_xcvr/tx_out_clk_0 axi_ad9152_dma/m_axis_aclk
ad_connect axi_ad9152_upack/s_axis axi_ad9152_dma/m_axis

ad_connect sys_dma_resetn axi_ad9680_dma/m_dest_axi_aresetn
ad_connect util_daq3_xcvr/rx_out_clk_0 axi_ad9680_dma/fifo_wr_clk
ad_connect axi_ad9680_cpack/packed_fifo_wr axi_ad9680_dma/fifo_wr

ad_mem_hp0_interconnect sys_cpu_clk sys_ps8/S_AXI_HP0
ad_mem_hp0_interconnect sys_cpu_clk axi_ad9680_xcvr/m_axi
ad_mem_hpc0_interconnect sys_dma_clk sys_ps8/S_AXI_HPC0
ad_mem_hpc0_interconnect sys_dma_clk axi_ad9680_dma/m_dest_axi
ad_mem_hpc1_interconnect sys_dma_clk sys_ps8/S_AXI_HPC1
ad_mem_hpc1_interconnect sys_dma_clk axi_ad9152_dma/m_src_axi
