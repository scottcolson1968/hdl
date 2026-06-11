###############################################################################
## Copyright (C) 2022-2025 Analog Devices, Inc. All rights reserved.
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

# ad35xxr_fmc SPI interface

set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS25} [get_ports {ad35xxr_spi_sdio[0]}]   ; # FMC_LA02_P    IO_L20P_T3_34
set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS25} [get_ports {ad35xxr_spi_sdio[1]}]   ; # FMC_LA02_N    IO_L20N_T3_34
set_property -dict {PACKAGE_PIN N22 IOSTANDARD LVCMOS25} [get_ports {ad35xxr_spi_sdio[2]}]   ; # FMC_LA03_P    IO_L16P_T2_34
set_property -dict {PACKAGE_PIN P22 IOSTANDARD LVCMOS25} [get_ports {ad35xxr_spi_sdio[3]}]   ; # FMC_LA03_N    IO_L16N_T2_34

set_property -dict {PACKAGE_PIN M19 IOSTANDARD LVCMOS25 } [get_ports ad35xxr_spi_sclk]       ; # FMC_LA00_CC_P IO_L13P_T2_MRCC_34
set_property -dict {PACKAGE_PIN M20 IOSTANDARD LVCMOS25 } [get_ports ad35xxr_spi_cs]         ; # FMC_LA00_CC_N IO_L13N_T2_MRCC_34

set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS25} [get_ports ad35xxr_ldacn]           ; # FMC_LA05_P    IO_L7P_T1_34
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS25} [get_ports ad35xxr_resetn]          ; # FMC_LA05_N    IO_L7N_T1_34
set_property -dict {PACKAGE_PIN M21 IOSTANDARD LVCMOS25} [get_ports ad35xxr_alertn]          ; # FMC_LA04_P    IO_L15P_T2_DQS_34
set_property -dict {PACKAGE_PIN M22 IOSTANDARD LVCMOS25} [get_ports ad35xxr_qspi_sel]        ; # FMC_LA04_N    IO_L15N_T2_DQS_34

set_property -dict {PACKAGE_PIN L21 IOSTANDARD LVCMOS25} [get_ports ad35xxr_gpio_6]          ; # FMC_LA06_P    IO_L10P_T1_34
set_property -dict {PACKAGE_PIN L22 IOSTANDARD LVCMOS25} [get_ports ad35xxr_gpio_7]          ; # FMC_LA06_N    IO_L10N_T1_34
set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS25} [get_ports ad35xxr_gpio_8]          ; # FMC_LA07_P    IO_L21P_T3_DQS_34
set_property -dict {PACKAGE_PIN T17 IOSTANDARD LVCMOS25} [get_ports ad35xxr_gpio_9]          ; # FMC_LA07_N    IO_L21N_T3_DQS_34
