###############################################################################
## Copyright (C) 2021-2025 Analog Devices, Inc. All rights reserved.
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
################################################################################

source ../../scripts/adi_env.tcl
source $ad_hdl_dir/projects/scripts/adi_project_xilinx.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

set p_device xczu3eg-sfva625-2-e

set sys_zynq 2

# 0 = Tx1 SSI reference clock
# 1 = Rx1 clocks
# 2 = Rx2 clocks
set USE_RX_CLK_FOR_TX1 [get_env_param USE_RX_CLK_FOR_TX1 0]
# 0 = Tx2 SSI reference clock
# 1 = Rx1 clocks
# 2 = Rx2 clocks
set USE_RX_CLK_FOR_TX2 [get_env_param USE_RX_CLK_FOR_TX2 0]

adi_project jupiter_sdr 0 [list \
  USE_RX_CLK_FOR_TX1 $USE_RX_CLK_FOR_TX1 \
  USE_RX_CLK_FOR_TX2 $USE_RX_CLK_FOR_TX2 \
]

adi_project_files jupiter_sdr [list \
  "system_top.v" \
  "system_constr.xdc" \
  "$ad_hdl_dir/library/common/ad_iobuf.v" ]

adi_project_run jupiter_sdr
