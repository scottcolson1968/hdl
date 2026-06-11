###############################################################################
## Copyright (C) 2019-2023 Analog Devices, Inc. All rights reserved.
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

global VIVADO_IP_LIBRARY

adi_ip_create axi_laser_driver
adi_ip_files axi_laser_driver [list \
  "$ad_hdl_dir/library/common/up_clock_mon.v" \
  "$ad_hdl_dir/library/xilinx/common/up_clock_mon_constr.xdc" \
  "axi_laser_driver_constr.xdc" \
  "axi_laser_driver_regmap.v" \
  "axi_laser_driver.v"]

adi_ip_properties axi_laser_driver
adi_ip_ttcl axi_laser_driver "../axi_pulse_gen/axi_pulse_gen_constr.ttcl"

set_property company_url {https://wiki.analog.com/resources/fpga/docs/axi_laser_driver} [ipx::current_core]

adi_ip_add_core_dependencies [list \
	analog.com:$VIVADO_IP_LIBRARY:util_cdc:1.0 \
	analog.com:$VIVADO_IP_LIBRARY:axi_pulse_gen:1.0 \
]

set cc [ipx::current_core]

set_property display_name "ADI AXI Laser Driver" $cc
set_property description  "ADI AXI Laser Driver" $cc

## define ext_clk port as a clock interface
adi_add_bus ext_clk slave \
  "xilinx.com:signal:clock_rtl:1.0" \
  "xilinx.com:signal:clock:1.0" \
  [list {"ext_clk" "CLK"} ]

adi_set_ports_dependency "ext_clk" \
  "(spirit:decode(id('MODELPARAM_VALUE.ASYNC_CLK_EN')) = 1)" 0

## Parameter validation

set_property -dict [list \
  "value_format" "bool" \
  "value" "true" \
 ] \
[ipx::get_user_parameters ASYNC_CLK_EN -of_objects $cc]

set_property -dict [list \
  "value_format" "bool" \
  "value" "true" \
 ] \
[ipx::get_hdl_parameters ASYNC_CLK_EN -of_objects $cc]

set_property -dict [list \
  "value_validation_type" "range_long" \
  "value_validation_range_minimum" "0" \
  "value_validation_range_maximum" "2147483647" \
 ] \
[ipx::get_user_parameters PULSE_WIDTH -of_objects $cc]

set_property -dict [list \
  "value_validation_type" "range_long" \
  "value_validation_range_minimum" "0" \
  "value_validation_range_maximum" "2147483647" \
 ] \
[ipx::get_user_parameters PULSE_PERIOD -of_objects $cc]

## Customize XGUI layout

## Remove the automatically generated GUI page
ipgui::remove_page -component $cc [ipgui::get_pagespec -name "Page 0" -component $cc]
ipx::save_core $cc

## Create a new GUI page

ipgui::add_page -name {AXI Pulse Generator} -component $cc -display_name {AXI Pulse Generator}
set page0 [ipgui::get_pagespec -name "AXI Pulse Generator" -component $cc]

ipgui::add_param -name "ASYNC_CLK_EN" -component $cc -parent $page0
set_property -dict [list \
  "display_name" "ASYNC_CLK_EN" \
  "tooltip" "External clock for the counter" \
  "widget" "checkBox" \
] [ipgui::get_guiparamspec -name "ASYNC_CLK_EN" -component $cc]

ipgui::add_param -name "PULSE_WIDTH" -component $cc -parent $page0
set_property -dict [list \
  "display_name" "Pulse width" \
  "tooltip" "Pulse width of the generated signal. The unit interval is the system or external clock period." \
] [ipgui::get_guiparamspec -name "PULSE_WIDTH" -component $cc]

ipgui::add_param -name "PULSE_PERIOD" -component $cc -parent $page0
set_property -dict [list \
  "display_name" "Pulse period" \
  "tooltip" "Period of the generated signal. The unit interval is the system or external clock period." \
] [ipgui::get_guiparamspec -name "PULSE_PERIOD" -component $cc]

## Save the modifications

ipx::create_xgui_files $cc
ipx::save_core $cc
