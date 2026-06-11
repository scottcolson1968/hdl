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

source ../../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_xilinx.tcl

adi_ip_create axi_ltc2387

adi_ip_files axi_ltc2387 [list \
  "$ad_hdl_dir/library/xilinx/common/ad_data_clk.v" \
  "$ad_hdl_dir/library/xilinx/common/ad_data_in.v" \
  "$ad_hdl_dir/library/common/up_adc_common.v" \
  "$ad_hdl_dir/library/common/up_adc_channel.v" \
  "$ad_hdl_dir/library/common/up_xfer_cntrl.v" \
  "$ad_hdl_dir/library/common/up_xfer_status.v" \
  "$ad_hdl_dir/library/common/up_clock_mon.v" \
  "$ad_hdl_dir/library/common/ad_datafmt.v" \
  "$ad_hdl_dir/library/common/ad_rst.v" \
  "$ad_hdl_dir/library/common/up_delay_cntrl.v" \
  "$ad_hdl_dir/library/common/up_axi.v" \
  "$ad_hdl_dir/library/xilinx/common/up_xfer_cntrl_constr.xdc" \
  "$ad_hdl_dir/library/xilinx/common/ad_rst_constr.xdc" \
  "$ad_hdl_dir/library/xilinx/common/ad_rst_constr.xdc" \
  "$ad_hdl_dir/library/xilinx/common/up_clock_mon_constr.xdc" \
  "$ad_hdl_dir/library/xilinx/common/up_xfer_status_constr.xdc" \
  "axi_ltc2387_if.v" \
  "axi_ltc2387_constr.xdc" \
  "axi_ltc2387_channel.v" \
  "axi_ltc2387.v" ]

adi_ip_properties axi_ltc2387

ipx::infer_bus_interface ref_clk xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::infer_bus_interface dco_p xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::infer_bus_interface dco_n xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]

set cc [ipx::current_core]

set page0 [ipgui::get_pagespec -name "Page 0" -component $cc]

ipx::add_user_parameter ADC_RES $cc
set_property value_resolve_type user [ipx::get_user_parameters ADC_RES -of_objects $cc]
ipgui::add_param -name "ADC_RES" -component $cc -parent $page0
set_property -dict [list \
  "display_name" "ADC resolution" \
  "tooltip" "ADC_RES" \
  "widget" "radioGroup" \
  "layout" "horizontal" \
] [ipgui::get_guiparamspec -name "ADC_RES" -component $cc]

set_property -dict [list \
  "value_format" "long" \
  "value_validation_type" "list" \
  "value_validation_list" "16 18" \
] [ipx::get_user_parameters ADC_RES -of_objects $cc]

ipx::add_user_parameter OUT_RES $cc
set_property value_resolve_type user [ipx::get_user_parameters OUT_RES -of_objects $cc]
ipgui::add_param -name "OUT_RES" -component $cc -parent $page0
set_property -dict [list \
  "display_name" "Output data width" \
  "tooltip" "OUT_RES" \
  "widget" "radioGroup" \
  "layout" "horizontal" \
] [ipgui::get_guiparamspec -name "OUT_RES" -component $cc]

set_property -dict [list \
  "value_format" "long" \
  "value_validation_type" "list" \
  "value_validation_list" "16 32" \
] [ipx::get_user_parameters OUT_RES -of_objects $cc]

ipx::add_user_parameter TWOLANES $cc
set_property value_resolve_type user [ipx::get_user_parameters TWOLANES -of_objects $cc]
ipgui::add_param -name "TWOLANES" -component $cc -parent $page0
set_property -dict [list \
  "display_name" "Lane mode" \
  "tooltip" "TWOLANES" \
  "widget" "radioGroup" \
  "layout" "horizontal" \
] [ipgui::get_guiparamspec -name "TWOLANES" -component $cc]

set_property -dict [list \
  "value_format" "long" \
  "value_validation_type" "list" \
  "value_validation_list" "0 1" \
] [ipx::get_user_parameters TWOLANES -of_objects $cc]

# if TWOLANES=0, disable and tie to GND, ports db_p, db_n
adi_set_ports_dependency "db_p" \
  "(spirit:decode(id('MODELPARAM_VALUE.TWOLANES')) == 1)"
adi_set_ports_dependency "db_n" \
  "(spirit:decode(id('MODELPARAM_VALUE.TWOLANES')) == 1)"

set_property driver_value 0 [ipx::get_ports -filter "direction==in" -of_objects $cc]

#adi_add_auto_fpga_spec_params

ipx::create_xgui_files $cc
ipx::update_checksums $cc
ipx::save_core $cc
