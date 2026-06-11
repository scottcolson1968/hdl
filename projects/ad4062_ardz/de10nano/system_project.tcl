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

set REQUIRED_QUARTUS_VERSION 24.1std.0
set QUARTUS_PRO_ISUSED 0
source ../../../scripts/adi_env.tcl
source ../../scripts/adi_project_intel.tcl

# get_env_param retrieves parameter value from the environment if exists,
# other case use the default value.
#
#   How to use over-writable parameters from the environment:
#
#    e.g.
#      make OFFLOAD=1
#
# Parameter description:
#
# OFFLOAD : Enable offload mode, includes AXI_DMAC and AXI_PWM to the design
#       1 - enabled
#       0 - disabled (default)

adi_project ad4062_ardz_de10nano [list \
  OFFLOAD [get_env_param OFFLOAD 0]]

source $ad_hdl_dir/projects/common/de10nano/de10nano_system_assign.tcl

# I3C interface bus

set_location_assignment PIN_AG11 -to i3c_scl ; ##   Arduino_IO15
set_location_assignment PIN_AH9  -to i3c_sda ; ##   Arduino_IO14

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to i3c_scl
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to i3c_sda

# Enable if not using an external 2.2k ohm passive pull-up
#set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to i3c_sda

# reset and GPIO signals

set_location_assignment PIN_AE15 -to common_shutdown      ; ##   Arduino_IO9
set_location_assignment PIN_AH8  -to common_reset_adc     ; ##   Arduino_IO7
set_location_assignment PIN_U13  -to common_csb_aux       ; ##   Arduino_IO5
set_location_assignment PIN_U14  -to common_sw_ff         ; ##   Arduino_IO4
set_location_assignment PIN_AG9  -to common_drdy_aux      ; ##   Arduino_IO3
set_location_assignment PIN_AF13 -to common_blue_led      ; ##   Arduino_IO1
set_location_assignment PIN_AG13 -to common_yellow_led    ; ##   Arduino_IO0

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to common_shutdown
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to common_reset_adc
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to common_csb_aux
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to common_sw_ff
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to common_drdy_aux
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to common_blue_led
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to common_yellow_led

# synchronization and timing

set_location_assignment PIN_AG8  -to common_sync_in       ; ##   arduino_IO6

set_instance_assignment -name io_standard "3.3-v lvttl" -to common_sync_in

execute_flow -compile
