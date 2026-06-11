###############################################################################
## Copyright (C) 2024 Analog Devices, Inc. All rights reserved.
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

adi_project ad411x_ad717x_de10nano

source $ad_hdl_dir/projects/common/de10nano/de10nano_system_assign.tcl

#
## down-grade Critical Warning related to asynchronous RAM in DMAC
#
## "mixed_port_feed_through_mode" parameter of RAM can not have value "old"

set_global_assignment -name MESSAGE_DISABLE 15003

# files

# ad411x_ad717x interface

set_location_assignment PIN_U14  -to error;      ## J7.5 Arduino_IO04
set_location_assignment PIN_AG9  -to sync_error; ## J7.4 Arduino_IO03

set_location_assignment PIN_AF15 -to spi_csn;    ## J5.3 Arduino_IO10
set_location_assignment PIN_AG16 -to spi_mosi;   ## J5.4 Arduino_IO11
set_location_assignment PIN_AH11 -to spi_miso;   ## J5.5 Arduino_IO12
set_location_assignment PIN_AH12 -to spi_clk;    ## J5.6 Arduino_IO13

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to error
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sync_error

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to spi_csn
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to spi_mosi
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to spi_miso
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to spi_clk

# I2C

set_location_assignment PIN_AG11  -to i2c_scl;   ## Arduino_IO15
set_location_assignment PIN_AH9   -to i2c_sda;   ## Arduino_IO14

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to i2c_scl
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to i2c_sda

set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to i2c_scl
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to i2c_sda

execute_flow -compile
