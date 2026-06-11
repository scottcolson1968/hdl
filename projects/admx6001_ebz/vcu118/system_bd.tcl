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

## FIFO depth is 4Mb - 250k samples (65k samples per converter)
set adc_fifo_address_width 13

source $ad_hdl_dir/projects/common/vcu118/vcu118_system_bd.tcl
source $ad_hdl_dir/projects/common/xilinx/adcfifo_bd.tcl
source $ad_hdl_dir/projects/admx6001_ebz/common/admx6001_ebz_bd.tcl
source $ad_hdl_dir/projects/scripts/adi_pd.tcl

# Set SPI clock to 100/16 =  6.25 MHz
ad_ip_parameter axi_spi     CONFIG.C_SCK_RATIO 16
ad_ip_parameter hmc7044_spi CONFIG.C_SCK_RATIO 16
ad_ip_parameter ad4080_spi  CONFIG.C_SCK_RATIO 16
ad_ip_parameter adl5580_spi CONFIG.C_SCK_RATIO 16
ad_ip_parameter ltc2664_spi CONFIG.C_SCK_RATIO 16

#system ID

ad_ip_parameter axi_sysid_0 CONFIG.ROM_ADDR_BITS 9
ad_ip_parameter rom_sys_0   CONFIG.PATH_TO_FILE "[pwd]/mem_init_sys.txt"
ad_ip_parameter rom_sys_0   CONFIG.ROM_ADDR_BITS 9

sysid_gen_sys_init_file

ad_ip_parameter util_adc_xcvr CONFIG.RX_CLK25_DIV 30
ad_ip_parameter util_adc_xcvr CONFIG.CPLL_CFG0 0x1fa
ad_ip_parameter util_adc_xcvr CONFIG.CPLL_CFG1 0x2b
ad_ip_parameter util_adc_xcvr CONFIG.CPLL_CFG2 0x2
ad_ip_parameter util_adc_xcvr CONFIG.CPLL_FBDIV 2
ad_ip_parameter util_adc_xcvr CONFIG.CH_HSPMUX 0x4040
ad_ip_parameter util_adc_xcvr CONFIG.PREIQ_FREQ_BST 1
ad_ip_parameter util_adc_xcvr CONFIG.RTX_BUF_CML_CTRL 0x5
ad_ip_parameter util_adc_xcvr CONFIG.RXPI_CFG0 0x3002
ad_ip_parameter util_adc_xcvr CONFIG.QPLL_REFCLK_DIV 1
ad_ip_parameter util_adc_xcvr CONFIG.QPLL_CFG0 0x333c
ad_ip_parameter util_adc_xcvr CONFIG.QPLL_CFG4 0x2
ad_ip_parameter util_adc_xcvr CONFIG.QPLL_FBDIV 20
ad_ip_parameter util_adc_xcvr CONFIG.PPF0_CFG 0xB00
