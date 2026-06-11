###############################################################################
## Copyright (C) 2019-2024 Analog Devices, Inc. All rights reserved.
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

## ADC FIFO depth in samples per converter
set adc_fifo_samples_per_converter [expr 64*1024]
## DAC FIFO depth in samples per converter
set dac_fifo_samples_per_converter [expr 64*1024]

source $ad_hdl_dir/projects/common/zcu102/zcu102_system_bd.tcl
source $ad_hdl_dir/projects/common/xilinx/adcfifo_bd.tcl
source $ad_hdl_dir/projects/common/xilinx/dacfifo_bd.tcl

ad_mem_hp0_interconnect $sys_cpu_clk sys_ps8/S_AXI_HP0

source $ad_hdl_dir/projects/ad9081_fmca_ebz/common/ad9081_fmca_ebz_bd.tcl
source $ad_hdl_dir/projects/scripts/adi_pd.tcl

#system ID
ad_ip_parameter axi_sysid_0 CONFIG.ROM_ADDR_BITS 10
ad_ip_parameter rom_sys_0 CONFIG.PATH_TO_FILE "$mem_init_sys_file_path/mem_init_sys.txt"
ad_ip_parameter rom_sys_0 CONFIG.ROM_ADDR_BITS 10

set SHARED_DEVCLK [ expr { [info exists ad_project_params(SHARED_DEVCLK)] \
                          ? $ad_project_params(SHARED_DEVCLK) : 0 } ]
set TDD_SUPPORT [ expr { [info exists ad_project_params(TDD_SUPPORT)] \
                          ? $ad_project_params(TDD_SUPPORT) : 0 } ]
set TDD_CHANNEL_CNT [ expr { [info exists ad_project_params(TDD_CHANNEL_CNT)] \
                          ? $ad_project_params(TDD_CHANNEL_CNT) : 0 } ]
set TDD_SYNC_WIDTH [ expr { [info exists ad_project_params(TDD_SYNC_WIDTH)] \
                          ? $ad_project_params(TDD_SYNC_WIDTH) : 0 } ]
set TDD_SYNC_INT [ expr { [info exists ad_project_params(TDD_SYNC_INT)] \
                          ? $ad_project_params(TDD_SYNC_INT) : 0 } ]
set TDD_SYNC_EXT [ expr { [info exists ad_project_params(TDD_SYNC_EXT)] \
                          ? $ad_project_params(TDD_SYNC_EXT) : 0 } ]
set TDD_SYNC_EXT_CDC [ expr { [info exists ad_project_params(TDD_SYNC_EXT_CDC)] \
                          ? $ad_project_params(TDD_SYNC_EXT_CDC) : 0 } ]

set sys_cstring "$ad_project_params(JESD_MODE)\
RX:RATE=$ad_project_params(RX_LANE_RATE)\
M=$ad_project_params(RX_JESD_M)\
L=$ad_project_params(RX_JESD_L)\
S=$ad_project_params(RX_JESD_S)\
NP=$ad_project_params(RX_JESD_NP)\
LINKS=$ad_project_params(RX_NUM_LINKS)\
TX:RATE=$ad_project_params(TX_LANE_RATE)\
M=$ad_project_params(TX_JESD_M)\
L=$ad_project_params(TX_JESD_L)\
S=$ad_project_params(TX_JESD_S)\
NP=$ad_project_params(TX_JESD_NP)\
LINKS=$ad_project_params(TX_NUM_LINKS)\
SHARED_DEVCLK=$SHARED_DEVCLK\
TDD:SUPPORT=$TDD_SUPPORT\
CHANNEL_CNT=$TDD_CHANNEL_CNT\
SYNC_WIDTH=$TDD_SYNC_WIDTH\
SYNC_INT=$TDD_SYNC_INT\
SYNC_EXT=$TDD_SYNC_EXT\
SYNC_EXT_CDC=$TDD_SYNC_EXT_CDC"

sysid_gen_sys_init_file $sys_cstring 10

# Parameters for 15.5Gpbs lane rate

ad_ip_parameter util_mxfe_xcvr CONFIG.RX_CLK25_DIV 31
ad_ip_parameter util_mxfe_xcvr CONFIG.TX_CLK25_DIV 31
ad_ip_parameter util_mxfe_xcvr CONFIG.CPLL_CFG0 0x1fa
ad_ip_parameter util_mxfe_xcvr CONFIG.CPLL_CFG1 0x23
ad_ip_parameter util_mxfe_xcvr CONFIG.CPLL_CFG2 0x2
ad_ip_parameter util_mxfe_xcvr CONFIG.CPLL_FBDIV 2
ad_ip_parameter util_mxfe_xcvr CONFIG.A_TXDIFFCTRL 0xc
ad_ip_parameter util_mxfe_xcvr CONFIG.RXCDR_CFG0 0x3
ad_ip_parameter util_mxfe_xcvr CONFIG.RXCDR_CFG2_GEN2 0x265
ad_ip_parameter util_mxfe_xcvr CONFIG.RXCDR_CFG2_GEN4 0x164
ad_ip_parameter util_mxfe_xcvr CONFIG.RXCDR_CFG3 0x1A
ad_ip_parameter util_mxfe_xcvr CONFIG.RXCDR_CFG3_GEN2 0x1A
ad_ip_parameter util_mxfe_xcvr CONFIG.RXCDR_CFG3_GEN3 0x1A
ad_ip_parameter util_mxfe_xcvr CONFIG.RXCDR_CFG3_GEN4 0x12
ad_ip_parameter util_mxfe_xcvr CONFIG.CH_HSPMUX 0x6868
ad_ip_parameter util_mxfe_xcvr CONFIG.PREIQ_FREQ_BST 1
ad_ip_parameter util_mxfe_xcvr CONFIG.RXPI_CFG0 0x4
ad_ip_parameter util_mxfe_xcvr CONFIG.RXPI_CFG1 0x0
ad_ip_parameter util_mxfe_xcvr CONFIG.TXPI_CFG 0x0
ad_ip_parameter util_mxfe_xcvr CONFIG.TX_PI_BIASSET 3

ad_ip_parameter util_mxfe_xcvr CONFIG.QPLL_REFCLK_DIV 1
ad_ip_parameter util_mxfe_xcvr CONFIG.POR_CFG 0x0
ad_ip_parameter util_mxfe_xcvr CONFIG.QPLL_CFG0 0x333c
ad_ip_parameter util_mxfe_xcvr CONFIG.QPLL_CFG4 0x45
ad_ip_parameter util_mxfe_xcvr CONFIG.QPLL_FBDIV 20
ad_ip_parameter util_mxfe_xcvr CONFIG.PPF0_CFG 0xF00
ad_ip_parameter util_mxfe_xcvr CONFIG.QPLL_CP 0xFF
ad_ip_parameter util_mxfe_xcvr CONFIG.QPLL_CP_G3 0xF
ad_ip_parameter util_mxfe_xcvr CONFIG.QPLL_LPF 0x2FF

# Overwrite parameter for lower lane rates which use CPLL
if {$ad_project_params(RX_LANE_RATE) < 12} {
  ad_ip_parameter util_mxfe_xcvr CONFIG.RX_WIDEMODE_CDR 0x0
  ad_ip_parameter util_mxfe_xcvr CONFIG.RXPI_CFG0 0x200
  ad_ip_parameter util_mxfe_xcvr CONFIG.RXPI_CFG1 0xFD

  ad_ip_parameter util_mxfe_xcvr CONFIG.RXCDR_CFG3 0x12
  ad_ip_parameter util_mxfe_xcvr CONFIG.RXCDR_CFG3_GEN2 0x12
  ad_ip_parameter util_mxfe_xcvr CONFIG.RXCDR_CFG3_GEN3 0x12
  ad_ip_parameter util_mxfe_xcvr CONFIG.RXCDR_CFG3_GEN4 0x12
}
