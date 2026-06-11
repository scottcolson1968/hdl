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

# SPI interface

set_property -dict {PACKAGE_PIN L17 IOSTANDARD LVCMOS33}                 [get_ports admx100x_spi_sclk]; ## D17   FMC_LA13_P
set_property -dict {PACKAGE_PIN K20 IOSTANDARD LVCMOS33}                 [get_ports admx100x_spi_miso]; ## C19   FMC_LA14_N
set_property -dict {PACKAGE_PIN J16 IOSTANDARD LVCMOS33}                 [get_ports admx100x_spi_mosi]; ## H19   FMC_LA15_P
set_property -dict {PACKAGE_PIN J20 IOSTANDARD LVCMOS33}                 [get_ports admx100x_spi_cs_0]; ## G18   FMC_LA16_P  CS_FPGA
set_property -dict {PACKAGE_PIN D22 IOSTANDARD LVCMOS33}                 [get_ports admx100x_spi_cs_1]; ## G27   FMC_LA25_P  CS_DAC

# reset and GPIO signal

set_property -dict {PACKAGE_PIN G19 IOSTANDARD LVCMOS33}                 [get_ports admx100x_reset];    ##G24   FMC_LA22_P  DAC_RESET
set_property -dict {PACKAGE_PIN R19 IOSTANDARD LVCMOS33}                 [get_ports admx100x_en];       ##C14   FMC_LA10_P
set_property -dict {PACKAGE_PIN R20 IOSTANDARD LVCMOS33}                 [get_ports admx100x_ready];    ##D14   FMC_LA09_P
set_property -dict {PACKAGE_PIN J21 IOSTANDARD LVCMOS33}                 [get_ports admx100x_valid];    ##G12   FMC_LA08_P
set_property -dict {PACKAGE_PIN E21 IOSTANDARD LVCMOS33}                 [get_ports admx100x_cal];      ##C26   FMC_LA27_P
set_property -dict {PACKAGE_PIN G20 IOSTANDARD LVCMOS33}                 [get_ports admx100x_dac_ldac]; ##G21   FMC_LA20_P
set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS33}                 [get_ports admx100x_trig];     ##H13   FMC_LA07_P
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33}                 [get_ports admx100x_ot];       ##H16   FMC_LA11_P

# syncronization
set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33}                 [get_ports admx100x_sync_mode]; ##H22  FMC_LA19_P  SYNC_MODE

# set IOSTANDARD according to VADJ 3.3V

set_property  -dict {IOSTANDARD LVCMOS33} [get_ports otg_vbusoc]

set_property  -dict {IOSTANDARD LVCMOS33} [get_ports gpio_bd[0]]       ; ## BTNC
set_property  -dict {IOSTANDARD LVCMOS33} [get_ports gpio_bd[1]]       ; ## BTND
set_property  -dict {IOSTANDARD LVCMOS33} [get_ports gpio_bd[2]]       ; ## BTNL
set_property  -dict {IOSTANDARD LVCMOS33} [get_ports gpio_bd[3]]       ; ## BTNR
set_property  -dict {IOSTANDARD LVCMOS33} [get_ports gpio_bd[4]]       ; ## BTNU

set_property  -dict {IOSTANDARD LVCMOS33} [get_ports gpio_bd[11]]      ; ## SW0
set_property  -dict {IOSTANDARD LVCMOS33} [get_ports gpio_bd[12]]      ; ## SW1
set_property  -dict {IOSTANDARD LVCMOS33} [get_ports gpio_bd[13]]      ; ## SW2
set_property  -dict {IOSTANDARD LVCMOS33} [get_ports gpio_bd[14]]      ; ## SW3
set_property  -dict {IOSTANDARD LVCMOS33} [get_ports gpio_bd[15]]      ; ## SW4
set_property  -dict {IOSTANDARD LVCMOS33} [get_ports gpio_bd[16]]      ; ## SW5
set_property  -dict {IOSTANDARD LVCMOS33} [get_ports gpio_bd[17]]      ; ## SW6
set_property  -dict {IOSTANDARD LVCMOS33} [get_ports gpio_bd[18]]      ; ## SW7

set_property  -dict {IOSTANDARD LVCMOS33} [get_ports gpio_bd[27]]      ; ## XADC-GIO0
set_property  -dict {IOSTANDARD LVCMOS33} [get_ports gpio_bd[28]]      ; ## XADC-GIO1
set_property  -dict {IOSTANDARD LVCMOS33} [get_ports gpio_bd[29]]      ; ## XADC-GIO2
set_property  -dict {IOSTANDARD LVCMOS33} [get_ports gpio_bd[30]]      ; ## XADC-GIO3

set_property  -dict {IOSTANDARD LVCMOS33} [get_ports gpio_bd[31]]      ; ## OTG-RESETN
