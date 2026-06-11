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

proc util_cdc_sync_bits_constr {inst {from {}}} {
  if {$from != {}} {
    set_false_path \
      -from [get_registers $from] \
      -to   [get_registers [format "%s%s" ${inst} {|cdc_sync_stage1[0]}]]
  } else {
    set_false_path \
      -to   [get_registers [format "%s%s" ${inst} {|cdc_sync_stage1[0]}]]
  }
}

proc util_cdc_sync_data_constr {inst} {
  util_cdc_sync_bits_constr ${inst}|sync_bits:i_sync_out ${inst}|in_toggle_d1
  util_cdc_sync_bits_constr ${inst}|sync_bits:i_sync_in ${inst}|out_toggle_d1

  # set_max_skew
  set_false_path \
    -from [get_registers [format "%s%s" ${inst} {|cdc_hold[*]}]] \
    -to   [get_registers [format "%s%s" ${inst} {|out_data[*]}]]
}

proc util_cdc_sync_event_constr {inst} {
  util_cdc_sync_bits_constr ${inst}|sync_bits:i_sync_out ${inst}|in_toggle_d1
  util_cdc_sync_bits_constr ${inst}|sync_bits:i_sync_in ${inst}|out_toggle_d1

  set cdc_hold_reg [get_registers -nowarn [format "%s%s" ${inst} {|cdc_hold[*]}]]

  # For a event synchronizer with one event there is no hold register
  if {[get_collection_size ${cdc_hold_reg}] != 0} {
    # set_max_skew
    set_false_path \
      -from ${cdc_hold_reg} \
      -to   [get_registers [format "%s%s" ${inst} {|out_event[*]}]]
  }
}
