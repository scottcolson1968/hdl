###############################################################################
## Copyright (C) 2021-2025 Analog Devices, Inc. All rights reserved.
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
#      make NUM_OF_SDI=4  CAPTURE_ZONE=2
#
#
# Parameter description:
#
# CLK_MODE : Clocking mode of the device's digital interface
#
#   0 - SPI Mode
#   1 - Echo-clock or Master clock mode
#
# NUM_OF_SDI : the number of MOSI lines of the SPI interface
#
#    1 - Interleaved mode
#    2 - 1 lane per channel
#    4 - 2 lanes per channel
#    8 - 4 lanes per channel
#
# CAPTURE_ZONE : the capture zone of the next sample
# There are two capture zones for AD4624-30:
#
#   1 - from negative edge of the BUSY line until the next CNV positive edge -20ns
#   2 - from the next consecutive CNV positive edge +20ns until the second next
#   consecutive CNV positive edge -20ns
#
# DDR_EN : in echo and master clock mode the SDI lines can have Single or Double
# Data Rates
#
#   0 - MISO runs on SDR
#   1 - MISO runs on DDR
#
# NO_REORDER : Parameter used for CAPTURE_ZONE = 1 and NUM_OF_SDI = 1 (ad4030)
# or NUM_OF_SDI = 2 (ad4630) to connect the SPI Engine directly to DMA bypassing
# the spi_axis_reorder IP
#
#   0 - spi_axis_reorder present in the system
#   1 - spi_axis_reorder removed from the system
#
# Example:
#
#   make NUM_OF_SDI=2 CAPTURE_ZONE=2
#

adi_project ad4630_fmc_zed 0 [list \
  CLK_MODE     [get_env_param CLK_MODE      0] \
  NUM_OF_SDI   [get_env_param NUM_OF_SDI    4] \
  CAPTURE_ZONE [get_env_param CAPTURE_ZONE  2] \
  DDR_EN       [get_env_param DDR_EN        0] \
  NO_REORDER   [get_env_param NO_REORDER    0] ]

adi_project_files ad4630_fmc_zed [list \
  "$ad_hdl_dir/library/common/ad_iobuf.v" \
  "$ad_hdl_dir/library/xilinx/common/ad_data_clk.v" \
  "$ad_hdl_dir/projects/common/zed/zed_system_constr.xdc" \
  "system_constr.xdc" \
  "system_top.v" ]

switch [get_env_param NUM_OF_SDI 4] {
  1 {
    adi_project_files ad4630_fmc_zed [list \
      "system_constr_1sdi.xdc" ]
  }
  2 {
    adi_project_files ad4630_fmc_zed [list \
      "system_constr_2sdi.xdc" ]
  }
  4 {
    adi_project_files ad4630_fmc_zed [list \
      "system_constr_4sdi.xdc" ]
  }
  8 {
    adi_project_files ad4630_fmc_zed [list \
      "system_constr_8sdi.xdc" ]
  }
  default {
    adi_project_files ad4630_fmc_zed [list \
      "system_constr_2sdi.xdc" ]
  }
}

adi_project_run ad4630_fmc_zed
