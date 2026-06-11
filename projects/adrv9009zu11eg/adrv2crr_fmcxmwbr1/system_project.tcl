###############################################################################
## Copyright (C) 2019-2023 Analog Devices, Inc. All rights reserved.
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

##-----------------------------------------------------------------------------
# IMPORTANT: Set interface mode
#
# The get_env_param procedure retrieves parameter value from the environment if
# exists, other case returns the default value specified in its second parameter
# field.
#
#   How to use over-writable parameters from the environment:
#
#    e.g.
#      make ADI_PRODUCTION = 0
#
#    ADI_PRODUCTION  - Defines the interface type (XMICROWAVE or FMCXMWBR1)
#
# LEGEND: 0 - FMCXMWBR1 - used for production testing
#         1 - XMICROWAVE - uses all the spi lines and gpios
#
##-----------------------------------------------------------------------------

set intf 0

if {[info exists ::env(ADI_PRODUCTION)]} {
  set intf $::env(ADI_PRODUCTION)
} else {
  set env(ADI_PRODUCTION) $intf
}

adi_project_create adrv9009zu11eg_fmcxmwbr1 0 [list \
  RX_JESD_M       [get_env_param RX_JESD_M     8] \
  RX_JESD_L       [get_env_param RX_JESD_L     4] \
  RX_JESD_S       [get_env_param RX_JESD_S     1] \
  TX_JESD_M       [get_env_param TX_JESD_M     8] \
  TX_JESD_L       [get_env_param TX_JESD_L     8] \
  TX_JESD_S       [get_env_param TX_JESD_S     1] \
  RX_OS_JESD_M    [get_env_param RX_OS_JESD_M  4] \
  RX_OS_JESD_L    [get_env_param RX_OS_JESD_L  4] \
  RX_OS_JESD_S    [get_env_param RX_OS_JESD_S  1] \
] "xczu11eg-ffvf1517-2-i"

adi_project_files adrv9009zu11eg_fmcxmwbr1 [list \
  "system_constr.xdc"\
  "../common/adrv9009zu11eg_spi.v" \
  "../common/adrv9009zu11eg_constr.xdc" \
  "../common/adrv2crr_fmc_constr.xdc" \
  "$ad_hdl_dir/library/common/ad_iobuf.v" ]

switch $intf {
  0 {
    adi_project_files adrv9009zu11eg_fmcxmwbr1 [list \
      "system_top_fmcxmwbr1.v" ]
  }
  1 {
    adi_project_files adrv9009zu11eg_fmcxmwbr1 [list \
      "system_top_xmicrowave.v" ]
  }
}

## To improve timing in DDR4 MIG
set_property strategy Performance_ExploreWithRemap [get_runs impl_1]

adi_project_run adrv9009zu11eg_fmcxmwbr1
