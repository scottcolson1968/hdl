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

# get_env_param retrieves parameter value from the environment if exists,
# other case use the default value
#
#   Use over-writable parameters from the environment.
#
#    e.g.
#      make RX_JESD_L=4 RX_JESD_M=8 RX_JESD_S=1 TX_JESD_L=4 TX_JESD_M=8 TX_JESD_S=1
#      make RX_JESD_L=8 RX_JESD_M=4 RX_JESD_S=1 TX_JESD_L=8 TX_JESD_M=4 TX_JESD_S=1
#      make RX_JESD_L=2 RX_JESD_M=8 RX_JESD_S=1 RX_JESD_NP=12 TX_JESD_L=2 TX_JESD_M=8 TX_JESD_S=1 TX_JESD_NP=12

#
# Parameter description:
#   JESD_MODE : Used link layer encoder mode
#      64B66B - 64b66b link layer defined in JESD 204C, uses Xilinx IP as Physical layer
#      8B10B  - 8b10b link layer defined in JESD 204B, uses ADI IP as Physical layer
#
#   RX_LANE_RATE :  Line rate of the Rx link ( MxFE to FPGA ) used in 64B66B mode
#   TX_LANE_RATE :  Line rate of the Tx link ( FPGA to MxFE ) used in 64B66B mode
#   [RX/TX]_JESD_M : Number of converters per link
#   [RX/TX]_JESD_L : Number of lanes per link
#   [RX/TX]_JESD_NP : Number of bits per sample
#   [RX/TX]_NUM_LINKS : Number of links
#
#  !!! For this carrier only 8B10B mode is supported !!!
#

adi_project ad9081_fmca_ebz_zc706 0 [list \
  JESD_MODE         8B10B \
  RX_LANE_RATE      [get_env_param RX_LANE_RATE      10 ] \
  TX_LANE_RATE      [get_env_param TX_LANE_RATE      10 ] \
  RX_JESD_M         [get_env_param RX_JESD_M          8 ] \
  RX_JESD_L         [get_env_param RX_JESD_L          4 ] \
  RX_JESD_S         [get_env_param RX_JESD_S          1 ] \
  RX_JESD_NP        [get_env_param RX_JESD_NP        16 ] \
  RX_NUM_LINKS      [get_env_param RX_NUM_LINKS       1 ] \
  TX_JESD_M         [get_env_param TX_JESD_M          8 ] \
  TX_JESD_L         [get_env_param TX_JESD_L          4 ] \
  TX_JESD_S         [get_env_param TX_JESD_S          1 ] \
  TX_JESD_NP        [get_env_param TX_JESD_NP        16 ] \
  TX_NUM_LINKS      [get_env_param TX_NUM_LINKS       1 ] \
]

adi_project_files ad9081_fmca_ebz_zc706 [list \
  "system_top.v" \
  "system_constr.xdc"\
  "timing_constr.xdc"\
  "../../../library/common/ad_3w_spi.v"\
  "$ad_hdl_dir/library/common/ad_iobuf.v" \
  "$ad_hdl_dir/projects/common/zc706/zc706_system_constr.xdc" ]

adi_project_run ad9081_fmca_ebz_zc706

