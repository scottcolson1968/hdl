###############################################################################
## Copyright (C) 2017-2023 Analog Devices, Inc. All rights reserved.
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

# report delays
set m_file [open "axi_ad9361_delay.log" w]
set m_ios [get_ports -filter {NAME =~ rx_*_in*}]
set m_ddr_ios [get_pins -hierarchical -filter {NAME =~ *i_rx_data_iddr/C || NAME =~ *i_rx_data_iddr/D}]
set m_info [report_timing -no_header -return_string -from $m_ios -to $m_ddr_ios -max_paths 100]

set m_sources {}
set m_string $m_info
while {[regexp {\s+Source:\s+(.*?)\s+(.*)} $m_string m1 m_value m_string] == 1} {
  lappend m_sources $m_value
}
set m_destinations {}
set m_string $m_info
while {[regexp {\s+Destination:\s+(.*?)\s+(.*)} $m_string m1 m_value m_string] == 1} {
  lappend m_destinations $m_value
}
set m_delays {}
set m_string $m_info
while {[regexp {\s+Data\s+Path\s+Delay:\s+(.*?)\s+(.*)} $m_string m1 m_value m_string] == 1} {
  lappend m_delays $m_value
}

set m_size [llength $m_sources]
if {[llength $m_destinations] != $m_size} {
  puts "CRITICAL WARNING: axi_ad9361_delay.tcl, source-destination size mismatch"
}
if {[llength $m_delays] != $m_size} {
  puts "CRITICAL WARNING: axi_ad9361_delay.tcl, source-delay size mismatch"
}

for {set m_index 0} {$m_index < $m_size} {incr m_index} {
  set m_delay [lindex $m_delays $m_index]
  set m_source [lindex $m_sources $m_index]
  set m_destination [lindex $m_destinations $m_index]
  puts "$m_source $m_destination $m_delay"
  puts $m_file "$m_source $m_destination $m_delay"
}

puts $m_file "\nDetails:\n"
puts $m_file $m_info
close $m_file

