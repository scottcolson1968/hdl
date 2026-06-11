###############################################################################
## Copyright (C) 2024-2025 Analog Devices, Inc. All rights reserved.
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
source $ad_hdl_dir/library/scripts/adi_ip_xilinx.tcl

# SPI interface

adi_if_define "spi_engine"
adi_if_ports output 1 sclk
adi_if_ports output 1 sdo
adi_if_ports output 1 sdo_t
adi_if_ports input -1 sdi
adi_if_ports output -1 cs
adi_if_ports output 1 three_wire

# Control interface

adi_if_define "spi_engine_ctrl"
adi_if_ports input 1 cmd_ready
adi_if_ports output 1 cmd_valid
adi_if_ports output 16 cmd_data
adi_if_ports input 1 sdo_ready
adi_if_ports output 1 sdo_valid
adi_if_ports output -1 sdo_data
adi_if_ports output 1 sdi_ready
adi_if_ports input 1 sdi_valid
adi_if_ports input -1 sdi_data
adi_if_ports output 1 sync_ready
adi_if_ports input 1 sync_valid
adi_if_ports input 8 sync_data

# Offload control interface

adi_if_define "spi_engine_offload_ctrl"
adi_if_ports output 1 cmd_wr_en
adi_if_ports output 16 cmd_wr_data
adi_if_ports output 1 sdo_wr_en
adi_if_ports output -1 sdo_wr_data
adi_if_ports output 1 mem_reset
adi_if_ports output 1 enable
adi_if_ports input 1 enabled
adi_if_ports output 1 sync_ready
adi_if_ports input 1 sync_valid
adi_if_ports input 8 sync_data

# Interconnect control interface

adi_if_define "spi_engine_interconnect_ctrl"
adi_if_ports  output 1 interconnect_dir
