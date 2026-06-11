###############################################################################
## Copyright (C) 2023-2025 Analog Devices, Inc. All rights reserved.
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

# get_env_param retrieves parameter value from the environment if exists,
# other case use the default value
#
# Use over-writable parameters from the environment.
#
# e.g.
#   RX-OS disabled: make
#   RX-OS Non-LinkSharing:
#    - JESD204B: make ORX_ENABLE=1 RX_OS_JESD_M=4 RX_OS_JESD_L=2 RX_OS_JESD_S=1 RX_OS_JESD_NP=16 RX_JESD_L=2 RX_TPL_WIDTH=8
#    - JESD204C: make JESD_MODE=64B66B ORX_ENABLE=1 TX_LANE_RATE=16.22 RX_LANE_RATE=16.22 \
                 RX_OS_JESD_M=4 RX_OS_JESD_L=2 RX_OS_JESD_S=1 RX_OS_JESD_NP=16 RX_JESD_L=2
#
# Parameter description:
#   JESD_MODE : Used link layer encoder mode
#      64B66B - 64b66b link layer defined in JESD 204C
#      8B10B  - 8b10b link layer defined in JESD 204B
#   ORX_ENABLE : Additional data path for RX-OS
#      0 - Disabled (used for profiles with RX-OS disabled)
#      1 - Enabled (used for profiles with RX-OS enabled)
#   TX_LANE_RATE : Transceiver line rate of the TX link
#   RX_LANE_RATE : Transceiver line rate of the RX link
#   [TX/RX/RX_OS]_NUM_LINKS : Number of links
#   [TX/RX/RX_OS]_JESD_M : Number of converters per link
#   [TX/RX/RX_OS]_JESD_L : Number of lanes per link
#   [TX/RX/RX_OS]_JESD_S : Number of samples per frame
#   [TX/RX/RX_OS]_JESD_NP : Number of bits per sample
#   [TX/RX/RX_OS]_TPL_WIDTH : TPL data path width in bits

adi_project adrv9026_zcu102 0 [list \
  JESD_MODE           [get_env_param JESD_MODE      8B10B ] \
  ORX_ENABLE          [get_env_param ORX_ENABLE         0 ] \
  TX_LANE_RATE        [get_env_param TX_LANE_RATE    9.83 ] \
  RX_LANE_RATE        [get_env_param RX_LANE_RATE    9.83 ] \
  TX_NUM_LINKS        [get_env_param TX_NUM_LINKS       1 ] \
  RX_NUM_LINKS        [get_env_param RX_NUM_LINKS       1 ] \
  RX_OS_NUM_LINKS     [get_env_param RX_OS_NUM_LINKS    1 ] \
  TX_JESD_M           [get_env_param TX_JESD_M          8 ] \
  TX_JESD_L           [get_env_param TX_JESD_L          4 ] \
  TX_JESD_S           [get_env_param TX_JESD_S          1 ] \
  TX_JESD_NP          [get_env_param TX_JESD_NP        16 ] \
  TX_TPL_WIDTH        [get_env_param TX_TPL_WIDTH      {} ] \
  RX_JESD_M           [get_env_param RX_JESD_M          8 ] \
  RX_JESD_L           [get_env_param RX_JESD_L          4 ] \
  RX_JESD_S           [get_env_param RX_JESD_S          1 ] \
  RX_JESD_NP          [get_env_param RX_JESD_NP        16 ] \
  RX_TPL_WIDTH        [get_env_param RX_TPL_WIDTH      {} ] \
  RX_OS_JESD_M        [get_env_param RX_OS_JESD_M       0 ] \
  RX_OS_JESD_L        [get_env_param RX_OS_JESD_L       0 ] \
  RX_OS_JESD_S        [get_env_param RX_OS_JESD_S       0 ] \
  RX_OS_JESD_NP       [get_env_param RX_OS_JESD_NP      0 ] \
  RX_OS_TPL_WIDTH     [get_env_param RX_OS_TPL_WIDTH   {} ] \
]
adi_project_files adrv9026_zcu102 [list \
  "system_top.v" \
  "system_constr.xdc"\
  "$ad_hdl_dir/library/common/ad_iobuf.v" \
  "$ad_hdl_dir/projects/common/zcu102/zcu102_system_constr.xdc" ]

set_property strategy Performance_RefinePlacement [get_runs impl_1]

adi_project_run adrv9026_zcu102
