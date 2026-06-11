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

set_property -dict {PACKAGE_PIN M18 IOSTANDARD LVCMOS33} [get_ports adc_gp0]
set_property -dict {PACKAGE_PIN N18 IOSTANDARD LVCMOS33} [get_ports adc_gp1]

# clk_fpga_0 is the first PL fabric clock, also called $sys_cpu_clk
set i3c_clk clk_fpga_0

# Input data driven the peripherals toggles every 4 cycles max (PP) of the capture clock
# gets registered by rx_reg
set_multicycle_path -from [get_ports iic_ard_sda] -to [get_clocks $i3c_clk] -setup 4
set_multicycle_path -from [get_ports iic_ard_sda] -to [get_clocks $i3c_clk] -hold 3

# Output data toggles every 2 cycles max of the capture clock (PP)
set_multicycle_path -from [get_clocks $i3c_clk] -to [get_ports iic_ard_sda] -setup 2
set_multicycle_path -from [get_clocks $i3c_clk] -to [get_ports iic_ard_sda] -hold 1
set_multicycle_path -from [get_clocks $i3c_clk] -to [get_ports iic_ard_scl] -setup 2
set_multicycle_path -from [get_clocks $i3c_clk] -to [get_ports iic_ard_scl] -hold 1

# Notes
# tcr/tcf rising/fall time for SCL is 150e06 * 1 / fSCL, at fSCL = 12.5 MHz => 12ns, at fSCL = 6.25 MHz, 24ns.
# and t_SCO has a minimum/default value of 8ns and max of 12 ns
# The input_delay and output_delay are selected for the worst case scenario.
# One i3c_clk clock cycle is included in the sdo signal to ensure thd_pp(min) is met.
set tsco_max   12;
set tsco_min    8;
set trc_dly_max 1;
set trc_dly_min 0;
set_input_delay  -clock $i3c_clk -max [expr $tsco_max + $trc_dly_max] [get_ports iic_ard_sda]
set_input_delay  -clock $i3c_clk -min [expr $tsco_min + $trc_dly_min] [get_ports iic_ard_sda]
set tsu         2;
set thd         0;
set_output_delay -clock $i3c_clk -max [expr $trc_dly_max + $tsu] [get_ports iic_ard_sda]
set_output_delay -clock $i3c_clk -min [expr $trc_dly_min - $thd] [get_ports iic_ard_sda]
set_output_delay -clock $i3c_clk -max [expr $trc_dly_max + $tsu] [get_ports iic_ard_scl]
set_output_delay -clock $i3c_clk -min [expr $trc_dly_min - $thd] [get_ports iic_ard_scl]
