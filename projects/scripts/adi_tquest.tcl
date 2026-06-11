###############################################################################
## Copyright (C) 2015-2023 Analog Devices, Inc. All rights reserved.
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

report_timing -detail full_path -npaths 20 -setup -file timing_impl.log
report_timing -detail full_path -npaths 20 -hold -append -file timing_impl.log
report_timing -detail full_path -npaths 20 -recovery -append -file timing_impl.log
report_timing -detail full_path -npaths 20 -removal -append -file timing_impl.log

set worst_path [get_timing_paths -npaths 1 -setup]
foreach_in_collection path $worst_path {
  set slack [get_path_info $path -slack]
}

if {$slack > 0} {
  set worst_path [get_timing_paths -npaths 1 -hold]
  foreach_in_collection path $worst_path {
    set slack [get_path_info $path -slack]
  }
}

if {$slack > 0} {
  set worst_path [get_timing_paths -npaths 1 -recovery]
  foreach_in_collection path $worst_path {
    set slack [get_path_info $path -slack]
  }
}

if {$slack > 0} {
  set worst_path [get_timing_paths -npaths 1 -removal]
  foreach_in_collection path $worst_path {
    set slack [get_path_info $path -slack]
  }
}

if {$slack < 0} {
  set sof_files [glob *.sof]
  foreach sof_file $sof_files {
    set root_sof_file [file rootname $sof_file]
    set new_sof_file [append root_sof_file "_timing.sof"]
    file rename -force $sof_file $new_sof_file
  }
  return -code error [format "ERROR: Timing Constraints NOT met!"]
}
