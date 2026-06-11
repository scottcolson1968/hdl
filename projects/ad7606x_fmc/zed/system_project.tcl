###############################################################################
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

# Parameter description
# INTF - Operation interface
#  - Options : Parallel(0)/Serial(1)
# NUM_OF_SDI - Number of SDI lines used
#  - Options: 1, 2, 4, 8
# ADC_N_BITS - ADC resolution
#  - Options: 16, 18

set NUM_OF_SDI [get_env_param NUM_OF_SDI 2]
set ADC_N_BITS [get_env_param ADC_N_BITS 16]
set INTF [get_env_param INTF 0]

adi_project ad7606x_fmc_zed 0 [list \
  INTF $INTF \
  NUM_OF_SDI $NUM_OF_SDI \
  ADC_N_BITS $ADC_N_BITS \
]

adi_project_files ad7606x_fmc_zed [list \
  "$ad_hdl_dir/library/common/ad_iobuf.v" \
  "$ad_hdl_dir/projects/common/zed/zed_system_constr.xdc"]

switch $INTF {
  0 {
    adi_project_files ad7606x_fmc_zed [list \
      "system_top_pi.v" \
      "system_constr_pif.xdc"]
  }
  1 {
    switch $NUM_OF_SDI {
      1 {
        adi_project_files ad7606x_fmc_zed [list \
          "system_top_si.v" \
          "system_constr_spi_1.xdc"]
      }

      2 {
        adi_project_files ad7606x_fmc_zed [list \
          "system_top_si.v" \
          "system_constr_spi_2.xdc"]
      }

      4 {
        adi_project_files ad7606x_fmc_zed [list \
          "system_top_si.v" \
          "system_constr_spi_4.xdc"]
      }

      8 {
        adi_project_files ad7606x_fmc_zed [list \
          "system_top_si.v" \
          "system_constr_spi_8.xdc"]
      }
    }
  }
}

adi_project_run ad7606x_fmc_zed
