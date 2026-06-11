###############################################################################
## Copyright (C) 2022-2024 Analog Devices, Inc. All rights reserved.
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

# In the case of:
# EVAL-AD7190 and EVAL-AD9175:
#   it works both connecting its PMOD to PMOD JA of Cora, and
#   placing it on top of Cora, connecting it to the Arduino header
# EVAL-AD7193: only ARDZ_PMOD_N=1;
#   works only by placing it on top of Cora, connecting it to the Arduino header

# make  or  make ARDZ_PMOD_N=0 - connect the eval board PMOD to PMOD JA of Cora
# make ARDZ_PMOD_N=1 - connect the eval board to the Arduino header (placing it on top of Cora)

source ../../../scripts/adi_env.tcl
source $ad_hdl_dir/projects/scripts/adi_project_xilinx.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

adi_project ad719x_asdz_coraz7s 0 [list \
  ARDZ_PMOD_N [get_env_param ARDZ_PMOD_N 0] \
]

adi_project_files ad719x_asdz_coraz7s [list \
    "$ad_hdl_dir/library/common/ad_iobuf.v" \
    "$ad_hdl_dir/projects/common/coraz7s/coraz7s_system_constr.xdc" \
]

switch [get_env_param ARDZ_PMOD_N 0] {
  0 {
    # PMOD
    adi_project_files {} [list \
      "system_constr_pmod.xdc" \
      "system_top_pmod.v" \
    ]
  }
  1 {
    # through Arduino header
    adi_project_files {} [list \
      "system_constr_ardz.xdc" \
      "system_top_ardz.v" \
    ]
  }
  default {
    # PMOD - default mode
    adi_project_files {} [list \
      "system_constr_pmod.xdc" \
      "system_top_pmod.v" \
    ]
  }
}

adi_project_run ad719x_asdz_coraz7s
