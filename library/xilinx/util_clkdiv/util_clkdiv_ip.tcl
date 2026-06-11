###############################################################################
## Copyright (C) 2016-2023 Analog Devices, Inc. All rights reserved.
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

source ../../../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_xilinx.tcl

adi_ip_create util_clkdiv
adi_ip_files util_clkdiv [list \
  "util_clkdiv_constr.xdc" \
  "util_clkdiv_ooc.ttcl" \
  "util_clkdiv.v" ]

adi_ip_properties_lite util_clkdiv

adi_ip_ttcl util_clkdiv "util_clkdiv_ooc.ttcl"

set_property processing_order LATE [ipx::get_files "util_clkdiv_constr.xdc" \
                  -of_objects [ipx::get_file_groups -of_objects [ipx::current_core] -filter {NAME =~ *synthesis*}]]

set_property driver_value 0 [ipx::get_ports clk_sel -of_objects [ipx::current_core]]

set_property value_validation_type list [ipx::get_user_parameters SIM_DEVICE -of_objects [ipx::current_core]]
set_property value_validation_list {7SERIES ULTRASCALE} [ipx::get_user_parameters SIM_DEVICE -of_objects [ipx::current_core]]

set_property value_validation_type list [ipx::get_user_parameters SEL_0_DIV -of_objects [ipx::current_core]]
set_property value_validation_list {1 2 3 4 5 6 7 8} [ipx::get_user_parameters SEL_0_DIV -of_objects [ipx::current_core]]

set_property value_validation_type list [ipx::get_user_parameters SEL_1_DIV -of_objects [ipx::current_core]]
set_property value_validation_list {1 2 3 4 5 6 7 8} [ipx::get_user_parameters SEL_1_DIV -of_objects [ipx::current_core]]

adi_add_bus clk_out master "xilinx.com:signal:clock_rtl:1.0" "xilinx.com:signal:clock:1.0" \
  [list {"clk_out" "CLK"}]

ipx::infer_bus_interface clk xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]

ipx::save_core [ipx::current_core]
