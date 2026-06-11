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

proc ad_ip_instance {i_ip i_name {i_params {}}} {
  add_instance ${i_name} ${i_ip}
  # Set parameters if provided
  if {$i_params != {}} {
    foreach {k v} $i_params {
      set_instance_parameter_value ${i_name} $k $v
    }
  }
}

proc ad_ip_parameter {i_name i_param i_value} {

    # Remove CONFIG. prefix if present for Intel
    regsub {^CONFIG\.} $i_param {} param_name
    set_instance_parameter_value ${i_name} ${param_name} ${i_value}
}

proc ad_connect {name_a name_b} {

    add_connection $name_a $name_b
}
