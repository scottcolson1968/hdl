###############################################################################
## Copyright (C) 2022-2025 Analog Devices, Inc. All rights reserved.
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

# load script
source ../../../scripts/adi_env.tcl
source $ad_hdl_dir/projects/scripts/adi_project_xilinx.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

# RESOLUTION_16_18N - The resolution of the ADC
# LEGEND: 18 BITS RESOLUTION AD7960 - 0
#         16 BITS RESOLUTION AD7626 - 1

adi_project pulsar_lvds_adc_zed 0 [list \
  RESOLUTION_16_18N [get_env_param RESOLUTION_16_18N 0] \
]

adi_project_files pulsar_lvds_adc_zed [list \
  "$ad_hdl_dir/library/xilinx/common/ad_data_clk.v" \
  "$ad_hdl_dir/library/common/ad_iobuf.v" \
  "$ad_hdl_dir/projects/common/zed/zed_system_constr.xdc" \
  "system_constr.xdc" \
  ]

 switch [get_env_param RESOLUTION_16_18N 0] {
  0 {
    adi_project_files pulsar_lvds_adc_zed [list \
      "system_top_ad7960.v" \
      "system_constr_18b.xdc" \
      ]
  }
  1 {
    adi_project_files pulsar_lvds_adc_zed [list \
      "system_top_ad7626.v" \
      "system_constr_16b.xdc" \
      ]
  }
}

adi_project_run pulsar_lvds_adc_zed
