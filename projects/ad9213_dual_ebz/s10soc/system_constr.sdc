###############################################################################
## Copyright (C) 2021-2023 Analog Devices, Inc. All rights reserved.
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

create_clock -period  "10.000 ns"     -name sys_clk_100mhz      [get_ports {sys_clk}]
create_clock -period  "3.2 ns"        -name ref_a_clk0          [get_ports {rx_ref_a_clk0}]
create_clock -period  "3.2 ns"        -name ref_a_clk1          [get_ports {rx_ref_a_clk1}]
create_clock -period  "3.2 ns"        -name ref_b_clk0          [get_ports {rx_ref_b_clk0}]
create_clock -period  "3.2 ns"        -name ref_b_clk1          [get_ports {rx_ref_b_clk1}]
create_clock -period  "3.2 ns"        -name device_clk          [get_ports {rx_device_clk_0}]

set_input_delay -clock {device_clk} 0.2 [get_ports {rx_sysref_a}]

set_false_path -from [get_registers *altera_reset_synchronizer:alt_rst_sync_uq1|altera_reset_synchronizer_int_chain_out*]
set_false_path -from [get_keepers -no_duplicates {i_system_bd|sys_gpio_out|sys_gpio_out|data_out[2]}] -to [get_keepers -no_duplicates {adc_swap_d1}]
