###############################################################################
## Copyright (C) 2016-2023 Analog Devices, Inc. All rights reserved.
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

set_property ASYNC_REG TRUE -quiet [get_cells -hier -filter {name =~ *up_rx_rst_done*}]
set_property ASYNC_REG TRUE -quiet [get_cells -hier -filter {name =~ *up_tx_rst_done*}]
set_property ASYNC_REG TRUE -quiet [get_cells -hier -filter {name =~ *rx_rate*}]
set_property ASYNC_REG TRUE -quiet [get_cells -hier -filter {name =~ *tx_rate*}]

set_false_path -to [get_cells -hier -filter {name =~ *up_rx_rst_done_m1_reg && IS_SEQUENTIAL}]
set_false_path -to [get_cells -hier -filter {name =~ *up_tx_rst_done_m1_reg && IS_SEQUENTIAL}]
set_false_path -to [get_cells -hier -filter {name =~ *rx_rate_m1_reg* && IS_SEQUENTIAL}]
set_false_path -to [get_cells -hier -filter {name =~ *tx_rate_m1_reg* && IS_SEQUENTIAL}]

# sync bits i_sync_bits_tx_prbs_in
set_false_path \
  -to [get_cells -quiet -hier *cdc_sync_stage1_reg* \
    -filter {NAME =~ *i_sync_bits_tx_prbs_in* && IS_SEQUENTIAL}
    ]

# sync bits i_sync_bits_rx_prbs_in
set_false_path \
  -to [get_cells -quiet -hier *cdc_sync_stage1_reg* \
    -filter {NAME =~ *i_sync_bits_rx_prbs_in* && IS_SEQUENTIAL}
    ]

# sync bits i_sync_bits_rx_prbs_out
set_false_path \
  -to [get_cells -quiet -hier *cdc_sync_stage1_reg* \
    -filter {NAME =~ *i_sync_bits_rx_prbs_out* && IS_SEQUENTIAL}
    ]

# sync bits i_sync_bits_rx_bufstatus_in
set_false_path \
  -to [get_cells -quiet -hier *cdc_sync_stage1_reg* \
    -filter {NAME =~ *i_sync_bits_rx_bufstatus_in* && IS_SEQUENTIAL}
    ]

# sync bits i_sync_bits_bufstatus_out
set_false_path \
  -to [get_cells -quiet -hier *cdc_sync_stage1_reg* \
    -filter {NAME =~ *i_sync_bits_bufstatus_out* && IS_SEQUENTIAL}]
    