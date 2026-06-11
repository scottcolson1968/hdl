###############################################################################
## Copyright (C) 2024 - 2025 Analog Devices, Inc. All rights reserved.
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

set mod_data [ipl::parse_module ./axi_clock_monitor.v]
set ip $::ipl::ip

set ip [ipl::add_ports_from_module -ip $ip -mod_data $mod_data]

set ip [ipl::general \
    -vlnv "analog.com:ip:axi_clock_monitor:1.0" \
    -display_name "ADI AXI clock monitor" \
    -supported_products {*} \
    -supported_platforms {esi radiant} \
    -href "https://wiki.analog.com/resources/fpga/docs/axi_clock_monitor" \
    -category "ADI" \
    -keywords "ADI IP" \
    -min_radiant_version "2023.2" \
    -min_esi_version "2023.2" -ip $ip]

set ip [ipl::add_memory_map -ip $ip \
    -name "axi_clock_monitor_mem_map" \
    -description "axi_clock_monitor_mem_map" \
    -baseAddress 0 \
    -range 4096 \
    -width 32]

set ip [ipl::add_axi_interfaces -ip $ip -mod_data $mod_data]

set ip [ipl::set_parameter -ip $ip \
    -id ID \
    -type param \
    -value_type int \
    -conn_mod axi_clock_monitor \
    -title {ID} \
    -default 0 \
    -output_formatter nostr \
    -group1 {General configurations} \
    -group2 Global]
set ip [ipl::set_parameter -ip $ip \
    -id NUM_OF_CLOCKS \
    -type param \
    -value_type int \
    -conn_mod axi_clock_monitor \
    -title {Number of clocks} \
    -default 1 \
    -output_formatter nostr \
    -value_range {(1, 16)} \
    -group1 {General configurations} \
    -group2 Global]

for {set i 0} {$i < 16} {incr i} {
    set ip [ipl::ignore_ports -ip $ip -portlist clock_$i \
        -expression "not(NUM_OF_CLOCKS > $i)"]
}

set ip [ipl::add_ip_files -ip $ip -dpath rtl -flist [list \
    "$ad_hdl_dir/library/common/up_axi.v" \
    "$ad_hdl_dir/library/common/up_clock_mon.v" \
    "axi_clock_monitor.v" ]]

ipl::generate_ip $ip
