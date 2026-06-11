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

set_false_path \
  -from [get_registers {*|i_regmap|up_tdd_burst_count[*]}] \
  -to [get_registers {*|i_counter|tdd_burst_count[*]}]

set_false_path \
  -from [get_registers {*|i_regmap|up_tdd_startup_delay[*]}] \
  -to [get_registers {*|i_counter|tdd_startup_delay[*]}]

set_false_path \
  -from [get_registers {*|i_regmap|up_tdd_frame_length[*]}] \
  -to [get_registers {*|i_counter|tdd_frame_length[*]}]

set_false_path \
  -to [get_registers {*|i_sync_gen|tdd_sync_m1}]

set_false_path \
  -from [get_registers {*|i_regmap|up_tdd_sync_period_low[*]}] \
  -to [get_registers {*|i_sync_gen|tdd_sync_period[*]}]

set_false_path \
  -from [get_registers {*|i_regmap|up_tdd_sync_period_high[*]}] \
  -to [get_registers {*|i_sync_gen|tdd_sync_period[*]}]

set_false_path \
  -from [get_registers {*|i_regmap|up_tdd_channel_pol[*]}] \
  -to [get_registers {*|[*].i_channel|ch_pol}]

set_false_path \
  -from [get_registers {*|i_regmap|*up_tdd_channel_on[*][*]}] \
  -to [get_registers {*|[*].i_channel|t_high[*]}]

set_false_path \
  -from [get_registers {*|i_regmap|*up_tdd_channel_off[*][*]}] \
  -to [get_registers {*|[*].i_channel|t_low[*]}]

util_cdc_sync_bits_constr {*|axi_tdd_regmap:i_regmap|sync_bits:i_tdd_control_sync}

util_cdc_sync_bits_constr {*|axi_tdd_regmap:i_regmap|sync_bits:i_tdd_ch_en_sync}

util_cdc_sync_data_constr {*|axi_tdd_regmap:i_regmap|sync_data:i_tdd_cstate_sync}

util_cdc_sync_event_constr {*|axi_tdd_regmap:i_regmap|sync_event:i_tdd_soft_sync}

