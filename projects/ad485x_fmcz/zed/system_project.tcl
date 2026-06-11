##############################################################################
## Copyright (C) 2023-2024 Analog Devices, Inc. All rights reserved.
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

# if the interface is not build defined, set CMOS as default inferface
# make LVDS_CMOS_N=1 for LVDS interface
set LVDS_CMOS_N 0
if [info exists ::env(LVDS_CMOS_N)] {
  set LVDS_CMOS_N $::env(LVDS_CMOS_N)
} else {
  set env(LVDS_CMOS_N) $LVDS_CMOS_N
}

set DEVICE "AD4858"
if [info exists ::env(DEVICE)] {
  set DEVICE $::env(DEVICE)
} else {
  set env(DEVICE) $DEVICE
}

adi_project ad485x_fmcz_zed 0 [list \
  LVDS_CMOS_N     $LVDS_CMOS_N \
  DEVICE          $DEVICE \
]

if {$LVDS_CMOS_N == "0"} {
  source ../common/config.tcl
  if {$numb_of_lanes == "4"} {
    adi_project_files {} [list \
      "system_top_cmos_quad.v" \
      "system_constr_cmos_quad.xdc" \
    ]
  } else {
    adi_project_files {} [list \
      "system_top_cmos_octa.v" \
      "system_constr_cmos_octa.xdc" \
    ]
  }
} else {
  adi_project_files {} [list \
    "system_top_lvds.v" \
    "system_constr_lvds.xdc" \
  ]
}

adi_project_files {} [list \
  "$ad_hdl_dir/projects/common/zed/zed_system_constr.xdc" \
  "$ad_hdl_dir/library/common/ad_iobuf.v" \
]

adi_project_run ad485x_fmcz_zed
