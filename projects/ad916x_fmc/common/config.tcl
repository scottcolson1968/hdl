###############################################################################
## Copyright (C) 2019-2025 Analog Devices, Inc. All rights reserved.
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

# Select the device and mode you want the project synthesise for, by setting the
# ADI_DAC_DEVICE, ADI_DAC_MODE or ADI_LANE_RATE environment variables:
#
# make ADI_LANE_RATE=4.16 ADI_DAC_DEVICE=AD9163 ADI_DAC_MODE=08
# 
# Or just run make without any parameters (will build for AD9162, Mode 08,
# 12.5 GHz)

# Default:
set device AD9162
set mode   08

if [info exists ::env(ADI_DAC_DEVICE)] {
  set device $::env(ADI_DAC_DEVICE)
} else {
  set env(ADI_DAC_DEVICE) $device
}

if [info exists ::env(ADI_DAC_MODE)] {
  set mode $::env(ADI_DAC_MODE)
} else {
  set env(ADI_DAC_MODE) $mode
}

# single link only
set num_links 1

# This reference design supports the following devices and modes:

# AD9161
#                 Mode M L S F HD N NP
set params(AD9161,01) {2 1 1 4 1 16 16}
set params(AD9161,02) {2 2 2 2 1 16 16}
set params(AD9161,03) {2 3 3 4 1 16 16}
set params(AD9161,04) {2 4 1 1 1 16 16}
set params(AD9161,06) {2 6 3 2 1 16 16}
set params(AD9161,08) {2 8 2 1 1 16 16}

# AD9162
#                 Mode M L S F HD N NP
set params(AD9162,01) {2 1 1 4 1 16 16}
set params(AD9162,02) {2 2 2 2 1 16 16}
set params(AD9162,03) {2 3 3 4 1 16 16}
set params(AD9162,04) {2 4 1 1 1 16 16}
set params(AD9162,06) {2 6 3 2 1 16 16}
set params(AD9162,08) {2 8 2 1 1 16 16}

# AD9163
#                 Mode M L S F HD N NP
set params(AD9163,01) {2 1 1 4 1 16 16}
set params(AD9163,02) {2 2 1 2 1 16 16}
set params(AD9163,03) {2 3 3 4 1 16 16}
set params(AD9163,04) {2 4 1 1 1 16 16}
set params(AD9163,06) {2 6 3 2 1 16 16}
set params(AD9163,08) {2 8 2 1 1 16 16}

# AD9164
#                 Mode M L S F HD N NP
set params(AD9164,01) {2 1 1 4 1 16 16}
set params(AD9164,02) {2 2 2 2 1 16 16}
set params(AD9164,03) {2 3 3 4 1 16 16}
set params(AD9164,04) {2 4 1 1 1 16 16}
set params(AD9164,06) {2 6 3 2 1 16 16}
set params(AD9164,08) {2 8 2 1 1 16 16}

# Internal procedures
proc get_config_param {param} {
  upvar device device
  upvar mode mode
  upvar params params

  set jesd_params {M L S F HD N NP}

  if {[info exists ::env($param)]} {
    return $::env($param)
  } else {
    set index [lsearch $jesd_params $param]
    return [lindex $params($device,$mode) $index]
  }
}
