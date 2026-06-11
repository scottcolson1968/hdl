###############################################################################
## Copyright (C) 2020-2023 Analog Devices, Inc. All rights reserved.
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

source ../../../scripts/adi_env.tcl
source $ad_hdl_dir/projects/scripts/adi_project_xilinx.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

# The get_env_param procedure retrieves parameter value from the environment if exists,
# other case returns the default value specified in its second parameter field.
#
#   How to use over-writable parameters from the environment:
#
#    e.g.
#      make CMOS_LVDS_N=0
#     or
#      make CMOS_LVDS_N=1
#
#
# Parameter description:
#   CMOS_LVDS_N - type of interface
#         0 - LVDS
#         1 - CMOS

set CMOS_LVDS_N [get_env_param CMOS_LVDS_N 0]

# USE_RX_CLK_FOR_TXn
# 0 = Txn SSI reference clock
# 1 = Rx1 clocks
# 2 = Rx2 clocks

adi_project adrv9001_dual_zcu102 0 [list \
  CMOS_LVDS_N $CMOS_LVDS_N \
  USE_RX_CLK_FOR_TX1     [get_env_param USE_RX_CLK_FOR_TX1   0] \
  USE_RX_CLK_FOR_TX2     [get_env_param USE_RX_CLK_FOR_TX2   0] \
]

adi_project_files {} [list \
  "system_top.v" \
  "system_constr.xdc"\
  "$ad_hdl_dir/library/common/ad_iobuf.v" \
  "$ad_hdl_dir/projects/common/zcu102/zcu102_system_constr.xdc" ]

if {$CMOS_LVDS_N == 0} {
  adi_project_files {} [list \
    "lvds_constr.xdc" \
  ]
} else {
  adi_project_files {} [list \
    "cmos_constr.xdc" \
  ]
}

adi_project_run adrv9001_dual_zcu102

