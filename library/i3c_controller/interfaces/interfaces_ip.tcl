###############################################################################
## Copyright (C) 2023 Analog Devices, Inc. All rights reserved.
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

# Bus interface

adi_if_define "i3c_controller"
adi_if_ports output 1 scl
adi_if_ports output 1 sdo
adi_if_ports input  1 sdi
adi_if_ports output 1 t

# Interface between Host Interface and Core for commands

adi_if_define "i3c_controller_cmdp"
adi_if_ports input   1 cmdp_ready
adi_if_ports output  1 cmdp_valid
adi_if_ports output 31 cmdp
adi_if_ports input   3 cmdp_error
adi_if_ports input   1 cmdp_nop
adi_if_ports input   1 cmdp_daa_trigger

# Interface between Host Interface and Core for register map access

adi_if_define "i3c_controller_rmap"
adi_if_ports output 2 rmap_ibi_config
adi_if_ports output 2 rmap_pp_sg
adi_if_ports input  7 rmap_dev_char_addr
adi_if_ports output 4 rmap_dev_char_data

# Interface between Host Interface and Core for data transfer

adi_if_define "i3c_controller_sdio"
adi_if_ports input  1  sdo_ready
adi_if_ports output 1  sdo_valid
adi_if_ports output 8  sdo
adi_if_ports output 1  sdi_ready
adi_if_ports input  1  sdi_valid
adi_if_ports input  1  sdi_last
adi_if_ports input  8  sdi
adi_if_ports output 1  ibi_ready
adi_if_ports input  1  ibi_valid
adi_if_ports input  15 ibi
