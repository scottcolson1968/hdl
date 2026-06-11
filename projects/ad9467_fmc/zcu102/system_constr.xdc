###############################################################################
## Copyright (C) 2014-2023, 2025 Analog Devices, Inc. All rights reserved.
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

# ad9467

set_property -dict {PACKAGE_PIN AA7     IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports adc_clk_in_p]         ; ## FMC_HPC0_CLK0_M2C_P
set_property -dict {PACKAGE_PIN AA6     IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports adc_clk_in_n]         ; ## FMC_HPC0_CLK0_M2C_N
set_property -dict {PACKAGE_PIN V4      IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports adc_data_or_p]        ; ## FMC_HPC0_LA08_P    
set_property -dict {PACKAGE_PIN V3      IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports adc_data_or_n]        ; ## FMC_HPC0_LA08_N    
set_property -dict {PACKAGE_PIN Y3      IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports adc_data_in_n[0]]     ; ## FMC_HPC0_LA00_CC_N 
set_property -dict {PACKAGE_PIN Y4      IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports adc_data_in_p[0]]     ; ## FMC_HPC0_LA00_CC_P 
set_property -dict {PACKAGE_PIN AB4     IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports adc_data_in_p[1]]     ; ## FMC_HPC0_LA01_CC_P 
set_property -dict {PACKAGE_PIN AC4     IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports adc_data_in_n[1]]     ; ## FMC_HPC0_LA01_CC_N 
set_property -dict {PACKAGE_PIN V2      IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports adc_data_in_p[2]]     ; ## FMC_HPC0_LA02_P    
set_property -dict {PACKAGE_PIN V1      IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports adc_data_in_n[2]]     ; ## FMC_HPC0_LA02_N    
set_property -dict {PACKAGE_PIN Y2      IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports adc_data_in_p[3]]     ; ## FMC_HPC0_LA03_P    
set_property -dict {PACKAGE_PIN Y1      IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports adc_data_in_n[3]]     ; ## FMC_HPC0_LA03_N    
set_property -dict {PACKAGE_PIN AA2     IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports adc_data_in_p[4]]     ; ## FMC_HPC0_LA04_P    
set_property -dict {PACKAGE_PIN AA1     IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports adc_data_in_n[4]]     ; ## FMC_HPC0_LA04_N    
set_property -dict {PACKAGE_PIN AB3     IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports adc_data_in_p[5]]     ; ## FMC_HPC0_LA05_P    
set_property -dict {PACKAGE_PIN AC3     IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports adc_data_in_n[5]]     ; ## FMC_HPC0_LA05_N    
set_property -dict {PACKAGE_PIN AC2     IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports adc_data_in_p[6]]     ; ## FMC_HPC0_LA06_P    
set_property -dict {PACKAGE_PIN AC1     IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports adc_data_in_n[6]]     ; ## FMC_HPC0_LA06_N    
set_property -dict {PACKAGE_PIN U5      IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports adc_data_in_p[7]]     ; ## FMC_HPC0_LA07_P    
set_property -dict {PACKAGE_PIN U4      IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports adc_data_in_n[7]]     ; ## FMC_HPC0_LA07_N    

## spi

set_property -dict {PACKAGE_PIN V11     IOSTANDARD LVCMOS18} [get_ports spi_csn_adc]                        ; ## FMC_HPC0_LA33_N
set_property -dict {PACKAGE_PIN V12     IOSTANDARD LVCMOS18} [get_ports spi_csn_clk]                        ; ## FMC_HPC0_LA33_P
set_property -dict {PACKAGE_PIN T11     IOSTANDARD LVCMOS18} [get_ports spi_clk]                            ; ## FMC_HPC0_LA32_N
set_property -dict {PACKAGE_PIN U11     IOSTANDARD LVCMOS18} [get_ports spi_sdio]                           ; ## FMC_HPC0_LA32_P

# clocks
create_clock -name adc_clk      -period 4.00 [get_ports adc_clk_in_p]
