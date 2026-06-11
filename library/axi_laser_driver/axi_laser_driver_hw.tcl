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

package require qsys 14.0
source ../../scripts/adi_env.tcl
source ../scripts/adi_ip_intel.tcl

set_module_property NAME axi_laser_driver
set_module_property DESCRIPTION "AXI Laser Driver IP for Lidar prototyping platform "
set_module_property VERSION 1.0
set_module_property GROUP "Analog Devices"
set_module_property DISPLAY_NAME axi_laser_driver

# source files

ad_ip_files axi_laser_driver [list \
  "$ad_hdl_dir/library/util_cdc/sync_bits.v" \
  "$ad_hdl_dir/library/util_cdc/sync_event.v" \
  "$ad_hdl_dir/library/common/ad_rst.v" \
  "$ad_hdl_dir/library/common/up_axi.v" \
  "$ad_hdl_dir/library/common/up_clock_mon.v" \
  "$ad_hdl_dir/library/common/util_pulse_gen.v" \
  "$ad_hdl_dir/library/axi_pulse_gen/axi_pulse_gen_regmap.v" \
  "$ad_hdl_dir/library/axi_pulse_gen/axi_pulse_gen_constr.sdc" \
  "axi_laser_driver_constr.sdc" \
  "axi_laser_driver_regmap.v" \
  "axi_laser_driver.v"]

# IP parameters

add_parameter ID INTEGER 0
set_parameter_property ID DEFAULT_VALUE 0
set_parameter_property ID DISPLAY_NAME "Core ID"
set_parameter_property ID UNITS None
set_parameter_property ID HDL_PARAMETER true

add_parameter ASYNC_CLK_EN INTEGER 0
set_parameter_property ASYNC_CLK_EN DEFAULT_VALUE 0
set_parameter_property ASYNC_CLK_EN DISPLAY_NAME "Asynchronous Clocks"
set_parameter_property ASYNC_CLK_EN DISPLAY_HINT boolean
set_parameter_property ASYNC_CLK_EN ALLOWED_RANGES { "0:Disabled" "1:Enabled"}
set_parameter_property ASYNC_CLK_EN HDL_PARAMETER true

add_parameter PULSE_WIDTH INTEGER 0
set_parameter_property PULSE_WIDTH DEFAULT_VALUE 0
set_parameter_property PULSE_WIDTH DISPLAY_NAME "PWM pulse width"
set_parameter_property PULSE_WIDTH UNITS None
set_parameter_property PULSE_WIDTH HDL_PARAMETER true

add_parameter PULSE_PERIOD INTEGER 0
set_parameter_property PULSE_PERIOD DEFAULT_VALUE 0
set_parameter_property PULSE_PERIOD DISPLAY_NAME "PWM period"
set_parameter_property PULSE_PERIOD UNITS None
set_parameter_property PULSE_PERIOD HDL_PARAMETER true

# AXI4 Memory Mapped Interface

ad_ip_intf_s_axi s_axi_aclk s_axi_aresetn 15

# Interrupt interface

add_interface interrupt_sender interrupt end
set_interface_property interrupt_sender associatedAddressablePoint s_axi
set_interface_property interrupt_sender associatedClock s_axi_clock
set_interface_property interrupt_sender associatedReset s_axi_reset
set_interface_property interrupt_sender ENABLED true
set_interface_property interrupt_sender EXPORT_OF ""
set_interface_property interrupt_sender PORT_NAME_MAP ""
set_interface_property interrupt_sender CMSIS_SVD_VARIABLES ""
set_interface_property interrupt_sender SVD_ADDRESS_GROUP ""

add_interface_port interrupt_sender irq irq Output 1

# external clock and control/status ports

ad_interface clock  ext_clk            input  1

ad_interface signal driver_en_n       output  1
ad_interface signal driver_pulse      output  1
ad_interface signal driver_otw_n       input  1
ad_interface reset  driver_dp_reset   output  1 if_ext_clk
ad_interface signal tia_chsel         output  8

