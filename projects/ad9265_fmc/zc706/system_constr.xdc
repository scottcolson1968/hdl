###############################################################################
## Copyright (C) 2014-2023 Analog Devices, Inc. All rights reserved.
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

# ad9265

set_property -dict {PACKAGE_PIN AG17    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_clk_in_p]         ;
set_property -dict {PACKAGE_PIN AG16    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_clk_in_n]         ;
set_property -dict {PACKAGE_PIN AF15    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_or_p]        ;
set_property -dict {PACKAGE_PIN AG15    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_or_n]        ;
set_property -dict {PACKAGE_PIN AH14    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_in_p[0]]     ;
set_property -dict {PACKAGE_PIN AH13    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_in_n[0]]     ;
set_property -dict {PACKAGE_PIN AB12    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_in_p[1]]     ;
set_property -dict {PACKAGE_PIN AC12    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_in_n[1]]     ;
set_property -dict {PACKAGE_PIN AA15    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_in_p[2]]     ;
set_property -dict {PACKAGE_PIN AA14    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_in_n[2]]     ;
set_property -dict {PACKAGE_PIN AD14    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_in_p[3]]     ;
set_property -dict {PACKAGE_PIN AD13    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_in_n[3]]     ;
set_property -dict {PACKAGE_PIN AJ15    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_in_p[4]]     ;
set_property -dict {PACKAGE_PIN AK15    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_in_n[4]]     ;
set_property -dict {PACKAGE_PIN AE16    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_in_p[5]]     ;
set_property -dict {PACKAGE_PIN AE15    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_in_n[5]]     ;
set_property -dict {PACKAGE_PIN AE12    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_in_p[6]]     ;
set_property -dict {PACKAGE_PIN AF12    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_in_n[6]]     ;
set_property -dict {PACKAGE_PIN AG12    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_in_p[7]]     ;
set_property -dict {PACKAGE_PIN AH12    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports adc_data_in_n[7]]     ;

## spi

set_property -dict {PACKAGE_PIN AA30    IOSTANDARD LVCMOS25} [get_ports spi_csn_adc]                        ;
set_property -dict {PACKAGE_PIN Y30     IOSTANDARD LVCMOS25} [get_ports spi_csn_clk]                        ;
set_property -dict {PACKAGE_PIN Y27     IOSTANDARD LVCMOS25} [get_ports spi_clk]                            ;
set_property -dict {PACKAGE_PIN Y26     IOSTANDARD LVCMOS25} [get_ports spi_sdio]                           ;

# clocks

create_clock -name adc_clk      -period 8.000 [get_ports adc_clk_in_p]
