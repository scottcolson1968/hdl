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

source ../../../scripts/adi_env.tcl
source $ad_hdl_dir/projects/scripts/adi_project_xilinx.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

##--------------------------------------------------------------
# IMPORTANT: Set AD7405/ADuM7701 operation and interface mode
#
#    LVDS_CMOS_N - Defines the type of the data line:
#    single ended (ADuM7701, AD7403) or differential (AD7405)
#
# LEGEND: single ended - 0
#         differential - 1
##--------------------------------------------------------------

adi_project ad7405_fmc_zed 0 [list \
  LVDS_CMOS_N [get_env_param LVDS_CMOS_N  0]
]

adi_project_files ad7405_fmc_zed [list \
  "$ad_hdl_dir/library/common/ad_iobuf.v" \
  "$ad_hdl_dir/projects/common/zed/zed_system_constr.xdc"]

switch [get_env_param LVDS_CMOS_N 0] {
  0 {
    adi_project_files ad7405_fmc_zed [list \
      "system_top_cmos.v" \
      "system_constr_cmos.xdc"]
  }

  1 {
    adi_project_files ad7405_fmc_zed [list \
      "system_top_lvds.v" \
      "system_constr_lvds.xdc"]
  }
  default {
    return -code error [format "ERROR: Invalid data line type! Define as \'1\' (single ended) or \'0\' (differential) ..."]
  }
}
adi_project_run ad7405_fmc_zed
