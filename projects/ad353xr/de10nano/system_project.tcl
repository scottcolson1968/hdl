###############################################################################
## Copyright (C) 2025 Analog Devices, Inc. All rights reserved.
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

set REQUIRED_QUARTUS_VERSION 24.1std.0
set QUARTUS_PRO_ISUSED 0
source ../../../scripts/adi_env.tcl
source ../../scripts/adi_project_intel.tcl

adi_project ad353xr_de10nano

source $ad_hdl_dir/projects/common/de10nano/de10nano_system_assign.tcl

# SPI connections
set_location_assignment PIN_AG18 -to spiml_clk      ; ## GPIO1 JP7 [33]
set_location_assignment PIN_AF18 -to spiml_miso     ; ## GPIO1 JP7 [35]
set_location_assignment PIN_AG15 -to spiml_mosi     ; ## GPIO1 JP7 [37]
set_location_assignment PIN_AE19 -to spiml_ss0      ; ## GPIO1 JP7 [39]

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to spiml_clk
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to spiml_clk_miso
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to spiml_clk_mosi
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to spiml_clk_ss0

# GPIO connections
set_location_assignment PIN_AE20 -to dac_resetb      ; ## GPIO1 JP7 [38]
set_location_assignment PIN_AE17 -to dac_ldacb       ; ## GPIO1 JP7 [40]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to dac_resetb
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to dac_ldacb

execute_flow -compile
