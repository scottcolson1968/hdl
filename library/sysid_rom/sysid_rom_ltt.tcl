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

source ../../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_lattice.tcl

set mod_data [ipl::parse_module ./sysid_rom.v]
set ip $::ipl::ip

set ip [ipl::add_ports_from_module -ip $ip -mod_data $mod_data]

set ip [ipl::general -ip $ip \
    -display_name "sysid_rom" \
    -supported_products {*} \
    -supported_platforms {esi radiant} \
    -href "<Web link to the IP docs>" \
    -vlnv "analog.com:ip:sysid_rom:1.0" \
    -category "CUSTOM_IP" \
    -keywords "sysid_rom" \
    -min_radiant_version "2023.2" \
    -min_esi_version "2023.2"]

# Use this only if you don't want to costumize the IP parameters!
set ip [ipl::add_parameters_from_module -ip $ip -mod_data $mod_data]

set ip [ipl::add_ip_files -ip $ip -dpath rtl -flist [list \
   sysid_rom.v \
]]

set ip [ipl::set_parameter -ip $ip \
   -id {PATH_TO_FILE} \
   -type param \
   -value_type string \
   -conn_mod {sysid_rom} \
   -default {sysid_init_file.mem} \
   -output_formatter str \
   -description "PATH_TO_FILE" \
   -group1 "PARAMS" \
   -group2 "GLOB"]

ipl::generate_ip $ip
