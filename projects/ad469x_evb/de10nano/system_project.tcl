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

# get_env_param retrieves parameter value from the environment if exists,
# other case use the default value
#
#   Use over-writable parameters from the environment.
#
#    e.g.
#      make SPI_4WIRE=0
#      make SPI_4WIRE=1

# Parameter description:
#
#   SPI_4WIRE - Defines if CNV signal is linked to PWM or to SPI_CS
#   0 - CNV signal is linked to PWM
#   1 - CNV signal is linked to SPI_CS

adi_project ad469x_evb_de10nano [list \
   SPI_4WIRE   [get_env_param SPI_4WIRE 0] \
]

source $ad_hdl_dir/projects/common/de10nano/de10nano_system_assign.tcl

# files

set_global_assignment -name VERILOG_FILE $ad_hdl_dir/library/common/ad_edge_detect.v
set_global_assignment -name VERILOG_FILE $ad_hdl_dir/library/util_cdc/sync_bits.v

# ad469x interface

set_location_assignment PIN_AH8  -to ad469x_spi_cnv        ; ##   P4.7 Arduino_IO07
set_location_assignment PIN_AG10 -to ad469x_resetn         ; ##   P4.5 Arduino_IO02

set_location_assignment PIN_AE15 -to ad469x_busy_alt_gp0   ; ##   P3.2 Arduino_IO09

set_location_assignment PIN_AF15 -to ad469x_spi_cs         ; ##   P3.3 Arduino_IO10
set_location_assignment PIN_AG16 -to ad469x_spi_sdo        ; ##   P3.4 Arduino_IO11
set_location_assignment PIN_AH11 -to ad469x_spi_sdi        ; ##   P3.5 Arduino_IO12
set_location_assignment PIN_AH12 -to ad469x_spi_sclk       ; ##   P3.6 Arduino_IO13

set_location_assignment PIN_AH9   -to i2c_sda              ; ##   P3.9 Arduino_IO14
set_location_assignment PIN_AG11  -to i2c_scl              ; ##   P3.10 Arduino_IO15

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ad469x_spi_cnv
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ad469x_resetn

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ad469x_busy_alt_gp0

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ad469x_spi_cs
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ad469x_spi_sdo
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ad469x_spi_sdi
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ad469x_spi_sclk

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to i2c_scl
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to i2c_sda

execute_flow -compile
