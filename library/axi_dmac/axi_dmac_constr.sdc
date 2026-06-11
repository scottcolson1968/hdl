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

set_false_path -to    [get_registers *axi_dmac*cdc_sync_stage1*]
set_false_path -from  [get_registers *axi_dmac*cdc_sync_fifo_ram*]
set_false_path -from  [get_registers *axi_dmac*eot_mem*]
set_false_path -from  [get_registers *axi_dmac*bl_mem*]

# Burst memory
set_false_path -from  [get_registers *axi_dmac*burst_len_mem*]

# Reset manager
set_false_path \
  -from [get_registers {*|axi_dmac_transfer:i_transfer|axi_dmac_reset_manager:i_reset_manager|do_reset}] \
  -to [get_pins -compatibility_mode {*|axi_dmac_transfer:i_transfer|axi_dmac_reset_manager:i_reset_manager|reset_gen[*].reset_async[*]|clrn}]

set_false_path \
  -from [get_registers {*|axi_dmac_transfer:i_transfer|axi_dmac_reset_manager:i_reset_manager|reset_gen[*].reset_async[0]}] \
  -to   [get_registers {*|axi_dmac_transfer:i_transfer|axi_dmac_reset_manager:i_reset_manager|reset_gen[*].reset_async[3]}]

set_false_path \
  -from [get_registers {*|axi_dmac_transfer:i_transfer|axi_dmac_reset_manager:i_reset_manager|reset_gen[*].reset_async[0]}] \
  -to [get_pins -compatibility_mode {*|axi_dmac_transfer:i_transfer|axi_dmac_reset_manager:i_reset_manager|reset_gen[*].reset_sync_in|clrn}]

set_false_path \
  -from [get_registers {*|axi_dmac_transfer:i_transfer|axi_dmac_reset_manager:i_reset_manager|reset_gen[*].reset_sync[0]}] \
  -to [get_pins -compatibility_mode {*|axi_dmac_transfer:i_transfer|axi_dmac_reset_manager:i_reset_manager|reset_gen[*].reset_sync_in|clrn}]

# Debug signals
set_false_path -from  [get_registers *axi_dmac*|*i_request_arb*|cdc_sync_stage2*]  -to [get_registers *axi_dmac*up_rdata*]
set_false_path -from  [get_registers *axi_dmac*|*i_request_arb*|*id*]              -to [get_registers *axi_dmac*up_rdata*]
set_false_path -from  [get_registers *axi_dmac*|*i_request_arb*|address*]          -to [get_registers *axi_dmac*up_rdata*]
set_false_path \
  -from [get_registers {*|axi_dmac_transfer:i_transfer|axi_dmac_reset_manager:i_reset_manager|reset_gen[*].reset_sync[0]}] \
  -to   [get_registers {*|axi_dmac_regmap:i_regmap|up_rdata[*]}]
