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
source $ad_hdl_dir/projects/scripts/adi_project_lattice_pb.tcl

## Default options for adi_project_pb #########################################
## if the -dev_select "manual" then the -device, -speed and -board options can
## be set manually.
# adi_project_pb template_lfcpnx \
#     -dev_select "auto" \
#     -ppath "." \
#     -device "" \
#     -board "" \
#     -speed "" \
#     -language "verilog" \
#     -cmd_list {{source ./system_pb.tcl}}
#     -psc "${env(TOOLRTF)}/../../templates/MachXO3D_Template01/MachXO3D_Template01.psc"
adi_project_pb template_lfcpnx -parameter_list [list \
  SYSMEM_INIT_FILE [get_env_param SYSMEM_INIT_FILE ""]]
