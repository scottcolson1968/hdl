###############################################################################
## Copyright (C) 2015-2024 Analog Devices, Inc. All rights reserved.
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

source ../../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_xilinx.tcl

adi_ip_create util_sigma_delta_spi
adi_ip_files util_sigma_delta_spi [list \
	  "util_sigma_delta_spi.v" \
]

adi_ip_properties_lite util_sigma_delta_spi

adi_add_bus "m_spi" "master" \
	"analog.com:interface:spi_engine_rtl:1.0" \
	"analog.com:interface:spi_engine:1.0" \
	{
		{"m_sclk" "SCLK"} \
		{"m_sdi" "SDI"} \
		{"m_sdo" "SDO"} \
		{"m_sdo_t" "SDO_T"} \
		{"m_cs" "CS"} \
	}

adi_add_bus "s_spi" "slave" \
	"analog.com:interface:spi_engine_rtl:1.0" \
	"analog.com:interface:spi_engine:1.0" \
	{
		{"s_sclk" "SCLK"} \
		{"s_sdi" "SDI"} \
		{"s_sdo" "SDO"} \
		{"s_sdo_t" "SDO_T"} \
		{"s_cs" "CS"} \
	}

adi_add_bus_clock "clk" "m_spi:s_spi" "resetn"

ipx::save_core [ipx::current_core]
