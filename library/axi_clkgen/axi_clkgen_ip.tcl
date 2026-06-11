###############################################################################
## Copyright (C) 2014-2025 Analog Devices, Inc. All rights reserved.
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

# ip
source ../../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_xilinx.tcl

adi_ip_create axi_clkgen
adi_ip_files axi_clkgen [list \
  "$ad_hdl_dir/library/common/ad_rst.v" \
  "$ad_hdl_dir/library/xilinx/common/ad_mmcm_drp.v" \
  "$ad_hdl_dir/library/common/up_axi.v" \
  "$ad_hdl_dir/library/common/up_clkgen.v" \
  "$ad_hdl_dir/library/scripts/adi_xilinx_device_info_enc.tcl" \
  "bd/bd.tcl" \
  "axi_clkgen.v" ]

set_property used_in_simulation false [get_files ./bd/bd.tcl]
set_property used_in_simulation false [get_files $ad_hdl_dir/library/scripts/adi_xilinx_device_info_enc.tcl]
set_property used_in_synthesis false [get_files ./bd/bd.tcl]
set_property used_in_synthesis false [get_files $ad_hdl_dir/library/scripts/adi_xilinx_device_info_enc.tcl]

adi_ip_properties axi_clkgen
adi_ip_bd axi_clkgen "bd/bd.tcl"

set_property company_url {https://wiki.analog.com/resources/fpga/docs/axi_clkgen} [ipx::current_core]

ipx::infer_bus_interface clk xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::infer_bus_interface clk2 xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::infer_bus_interface clk_0 xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::infer_bus_interface clk_1 xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]

set cc [ipx::current_core]
set page0 [ipgui::get_pagespec -name "Page 0" -component $cc]

set param [ipx::add_user_parameter ENABLE_CLKIN2 $cc]
set_property -dict {value_resolve_type user value_format bool value false} $param

set param [ipgui::add_param -name {ENABLE_CLKIN2} -component $cc -parent $page0]
set_property -dict [list \
	display_name {Enable secondary clock input} \
	widget {checkBox} \
] $param

set param [ipx::add_user_parameter ENABLE_CLKOUT1 $cc]
set_property -dict {value_resolve_type user value_format bool value false} $param

set param [ipgui::add_param -name {ENABLE_CLKOUT1} -component $cc -parent $page0]
set_property -dict [list \
	display_name {Enable secondary clock output} \
	widget {checkBox} \
] $param

adi_add_auto_fpga_spec_params
ipx::create_xgui_files [ipx::current_core]

set_property enablement_tcl_expr {$ENABLE_CLKIN2} [ipx::get_user_parameters CLKIN2_PERIOD -of_objects $cc]
set_property enablement_tcl_expr {$ENABLE_CLKOUT1} [ipx::get_user_parameters CLK1_DIV -of_objects $cc]
set_property enablement_tcl_expr {$ENABLE_CLKOUT1} [ipx::get_user_parameters CLK1_PHASE -of_objects $cc]

adi_set_ports_dependency clk2 ENABLE_CLKIN2 0
adi_set_ports_dependency clk_1 ENABLE_CLKOUT1

ipx::create_xgui_files $cc
ipx::save_core $cc
