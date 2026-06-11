###############################################################################
## Copyright (C) 2015-2025 Analog Devices, Inc. All rights reserved.
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

adi_ip_create spi_engine_interconnect
adi_ip_files spi_engine_interconnect [list \
	"spi_engine_interconnect.v" \
]

adi_ip_properties_lite spi_engine_interconnect

set_property company_url {https://wiki.analog.com/resources/fpga/peripherals/spi_engine/interconnect} [ipx::current_core]

# Remove all inferred interfaces
ipx::remove_all_bus_interface [ipx::current_core]

## Interface definitions

adi_add_bus "m_ctrl" "master" \
	"analog.com:interface:spi_engine_ctrl_rtl:1.0" \
	"analog.com:interface:spi_engine_ctrl:1.0" \
	{ \
		{"m_cmd_ready" "cmd_ready"} \
		{"m_cmd_valid" "cmd_valid"} \
		{"m_cmd_data" "cmd_data"} \
		{"m_sdo_ready" "sdo_ready"} \
		{"m_sdo_valid" "sdo_valid"} \
		{"m_sdo_data" "sdo_data"} \
		{"m_sdi_ready" "sdi_ready"} \
		{"m_sdi_valid" "sdi_valid"} \
		{"m_sdi_data" "sdi_data"} \
		{"m_sync_ready" "sync_ready"} \
		{"m_sync_valid" "sync_valid"} \
		{"m_sync" "sync_data"} \
	}
adi_add_bus_clock "clk" "m_ctrl" "resetn"

adi_add_bus "s_interconnect_ctrl" "slave" \
	"analog.com:interface:spi_engine_interconnect_ctrl_rtl:1.0" \
	"analog.com:interface:spi_engine_interconnect_ctrl:1.0" \
	{ \
		{"interconnect_dir" "interconnect_dir"} \
	}
adi_add_bus_clock "clk" "s_interconnect_ctrl" "resetn"

foreach prefix [list "s0" "s1"] {
	adi_add_bus [format "%s_ctrl" $prefix] "slave" \
		"analog.com:interface:spi_engine_ctrl_rtl:1.0" \
		"analog.com:interface:spi_engine_ctrl:1.0" \
		[list \
			[list [format "%s_cmd_ready" $prefix] "cmd_ready"] \
			[list [format "%s_cmd_valid" $prefix] "cmd_valid"] \
			[list [format "%s_cmd_data" $prefix] "cmd_data"] \
			[list [format "%s_sdo_ready" $prefix] "sdo_ready"] \
			[list [format "%s_sdo_valid" $prefix] "sdo_valid"] \
			[list [format "%s_sdo_data" $prefix] "sdo_data"] \
			[list [format "%s_sdi_ready" $prefix] "sdi_ready"] \
			[list [format "%s_sdi_valid" $prefix] "sdi_valid"] \
			[list [format "%s_sdi_data" $prefix] "sdi_data"] \
			[list [format "%s_sync_ready" $prefix] "sync_ready"] \
			[list [format "%s_sync_valid" $prefix] "sync_valid"] \
			[list [format "%s_sync" $prefix] "sync_data"] \
		]
	adi_add_bus_clock "clk" [format "%s_ctrl" $prefix] "resetn"
}

## Parameter validations

set cc [ipx::current_core]

## DATA_WIDTH
set_property -dict [list \
  "value_validation_type" "range_long" \
  "value_validation_range_minimum" "8" \
  "value_validation_range_maximum" "256" \
 ] \
 [ipx::get_user_parameters DATA_WIDTH -of_objects $cc]

## NUM_OF_SDI
set_property -dict [list \
  "value_validation_type" "range_long" \
  "value_validation_range_minimum" "1" \
  "value_validation_range_maximum" "8" \
 ] \
 [ipx::get_user_parameters NUM_OF_SDI -of_objects $cc]

## Customize IP Layout

## Remove the automatically generated GUI page
ipgui::remove_page -component $cc [ipgui::get_pagespec -name "Page 0" -component $cc]
ipx::save_core [ipx::current_core]

## Create general configuration page
ipgui::add_page -name {SPI Engine interconnect} -component [ipx::current_core] -display_name {SPI Engine interconnect}
set page0 [ipgui::get_pagespec -name "SPI Engine interconnect" -component $cc]

set general_group [ipgui::add_group -name "General Configuration" -component $cc \
    -parent $page0 -display_name "General Configuration" ]

ipgui::add_param -name "DATA_WIDTH" -component $cc -parent $general_group
set_property -dict [list \
  "display_name" "Parallel data width" \
  "tooltip" "\[DATA_WIDTH\] Define the data interface width"
] [ipgui::get_guiparamspec -name "DATA_WIDTH" -component $cc]

ipgui::add_param -name "NUM_OF_SDI" -component $cc -parent $general_group
set_property -dict [list \
  "display_name" "Number of MISO lines" \
  "tooltip" "\[NUM_OF_SDI\] Define the number of MISO lines" \
] [ipgui::get_guiparamspec -name "NUM_OF_SDI" -component $cc]

## Create and save the XGUI file
ipx::create_xgui_files $cc

ipx::save_core [ipx::current_core]
