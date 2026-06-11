###############################################################################
## Copyright (C) 2022-2023 Analog Devices, Inc. All rights reserved.
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

package require qsys

source ../../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_intel.tcl

ad_ip_create axi_clock_monitor {axi_clock_monitor} p_axi_clock_monitor

# files
set_module_property NAME axi_clock_monitor

ad_ip_files axi_clock_monitor [list \
  $ad_hdl_dir/library/common/up_axi.v \
  $ad_hdl_dir/library/intel/common/up_clock_mon_constr.sdc \
  $ad_hdl_dir/library/intel/common/up_rst_constr.sdc \
  axi_clock_monitor.v \
]

# parameters

add_parameter NUM_OF_CLOCKS INTEGER 0
set_parameter_property NUM_OF_CLOCKS DEFAULT_VALUE 8
set_parameter_property NUM_OF_CLOCKS DISPLAY_NAME NUM_OF_CLOCKS
set_parameter_property NUM_OF_CLOCKS UNITS None
set_parameter_property NUM_OF_CLOCKS HDL_PARAMETER true

# interfaces

ad_ip_intf_s_axi s_axi_aclk s_axi_aresetn

ad_interface reset   output   1  if_reset

proc p_axi_clock_monitor {} {
  set num_of_clock [get_parameter_value NUM_OF_CLOCKS]

   for {set n 0} {$n < $num_of_clock} {incr n} {
    ad_interface clock  clock_${n}  input   1
  }
}

