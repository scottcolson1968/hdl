###############################################################################
## Copyright (C) 2019-2024 Analog Devices, Inc. All rights reserved.
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

# Parameter description

# ALERT_SPI_N - SDOB-SDOD/ALERT pin can operate as a serial data output pin or alert indication output
#  - Options : SDOB-SDOD(0)/ALERT(1)
# NUM_OF_SDI - Number of SDI lines used
#  - Options : 1,2,4

adi_project ad738x_fmc_zed 0 [list \
  ALERT_SPI_N [get_env_param ALERT_SPI_N  0]\
  NUM_OF_SDI [get_env_param NUM_OF_SDI    1] ]

adi_project_files ad738x_fmc_zed [list \
    "$ad_hdl_dir/library/common/ad_iobuf.v" \
    "$ad_hdl_dir/projects/common/zed/zed_system_constr.xdc" \
    "system_constr.xdc" \
    "system_top.v" ]

switch [get_env_param NUM_OF_SDI 1] {
  1 {
    adi_project_files ad738x_fmc_zed [list \
      "system_constr_1sdi.xdc" ]
  }
  2 {
    adi_project_files ad738x_fmc_zed [list \
     "system_constr_2sdi.xdc" ]
 }
  4 {
   adi_project_files ad738x_fmc_zed [list \
     "system_constr_4sdi.xdc" ]
  }
  default {
    adi_project_files ad738x_fmc_zed [list \
      "system_constr_1sdi.xdc" ]
  }
}

adi_project_run ad738x_fmc_zed
