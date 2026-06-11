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

set_property  -dict {PACKAGE_PIN  L18  IOSTANDARD LVCMOS25}  [get_ports adc_clk_in] ;     #H4      FMC_CLK0_M2C_P        L18       IO_L12P_T1_MRCC_34
set_property  -dict {PACKAGE_PIN  M19  IOSTANDARD LVCMOS25}  [get_ports adc_ready_in] ;   #G6      FMC_LA00_CC_P         M19       IO_L13P_T2_MRCC_34
set_property  -dict {PACKAGE_PIN  M20  IOSTANDARD LVCMOS25}  [get_ports adc_data_in[0]] ; #G7      FMC_LA00_CC_N         M20       IO_L13N_T2_MRCC_34
set_property  -dict {PACKAGE_PIN  L22  IOSTANDARD LVCMOS25}  [get_ports adc_data_in[1]] ; #C11     FMC_LA06_N            L22       IO_L10N_T1_34
set_property  -dict {PACKAGE_PIN  P17  IOSTANDARD LVCMOS25}  [get_ports adc_data_in[2]] ; #H7      FMC_LA02_P            P17       IO_L20P_T3_34
set_property  -dict {PACKAGE_PIN  P18  IOSTANDARD LVCMOS25}  [get_ports adc_data_in[3]] ; #H8      FMC_LA02_N            P18       IO_L20N_T3_34

set_property  -dict {PACKAGE_PIN   L21  IOSTANDARD LVCMOS25}  [get_ports reset_n] ;       #C10     FMC_LA06_P            L21       IO_L10P_T1_34
set_property  -dict {PACKAGE_PIN   P22  IOSTANDARD LVCMOS25}  [get_ports start_n] ;       #G10     FMC_LA03_N            P22       IO_L16N_T2_34
set_property  -dict {PACKAGE_PIN   R20  IOSTANDARD LVCMOS25}  [get_ports sdp_convst] ;    #D14     FMC_LA09_P            R20       IO_L17P_T2_34
set_property  -dict {PACKAGE_PIN   R19  IOSTANDARD LVCMOS25}  [get_ports alert] ;         #C14     FMC_LA10_P            R19       IO_L22P_T3_34
set_property  -dict {PACKAGE_PIN   M21  IOSTANDARD LVCMOS25}  [get_ports sync_adc_mosi] ; #H10     FMC_LA04_P            M21       IO_L15P_T2_DQS_34
set_property  -dict {PACKAGE_PIN   A22  IOSTANDARD LVCMOS25}  [get_ports gpio2] ;         #H38     FMC_LA32_N            A22       IO_L15N_T2_DQS_AD12N_35
set_property  -dict {PACKAGE_PIN   N20  IOSTANDARD LVCMOS25}  [get_ports sdp_mclk] ;      #D9      FMC_LA01_CC_N         N20       IO_L14N_T2_SRCC_34

set_property  -dict {PACKAGE_PIN   J18  IOSTANDARD LVCMOS25}  [get_ports spi_csn] ;  #D11     FMC_LA05_P            J18       IO_L7P_T1_34
set_property  -dict {PACKAGE_PIN   M22  IOSTANDARD LVCMOS25}  [get_ports spi_mosi] ; #H11     FMC_LA04_N            M22       IO_L15N_T2_DQS_34
set_property  -dict {PACKAGE_PIN   N22  IOSTANDARD LVCMOS25}  [get_ports spi_miso] ; #G9      FMC_LA03_P            N22       IO_L16P_T2_34
set_property  -dict {PACKAGE_PIN   N19  IOSTANDARD LVCMOS25}  [get_ports spi_clk] ;  #D8      FMC_LA01_CC_P         N19       IO_L14P_T2_SRCC_34

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets adc_clk_in]
create_clock -name adc_clk -period 488   [get_ports adc_clk_in]

set fall_min            224;       # period/2(=244) - skew_bfe(=20)
set fall_max            264;       # period/2(=244) + skew_are(=20)

set_input_delay -clock adc_clk -max  $fall_max  [get_ports adc_data_in[*]] -clock_fall -add_delay;
set_input_delay -clock adc_clk -min  $fall_min  [get_ports adc_data_in[*]] -clock_fall -add_delay;

set_input_delay -clock adc_clk -min  $fall_min  [get_ports adc_ready_in  ] -clock_fall -add_delay;
set_input_delay -clock adc_clk -min  $fall_min  [get_ports adc_ready_in  ] -clock_fall -add_delay;
