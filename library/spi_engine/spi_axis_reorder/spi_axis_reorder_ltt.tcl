###############################################################################
## Copyright (C) 2024 - 2025 Analog Devices, Inc. All rights reserved.
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
source $ad_hdl_dir/library/scripts/adi_ip_lattice.tcl

set mod_data [ipl::parse_module ./spi_axis_reorder.v]
set ip $::ipl::ip

set ip [ipl::add_ports_from_module -ip $ip -mod_data $mod_data]

set ip [ipl::general \
    -vlnv "analog.com:ip:spi_axis_reorder:1.0" \
    -category "ADI" \
    -keywords "ADI IP" \
    -min_radiant_version "2023.2" \
    -min_esi_version "2023.2" -ip $ip]

set ip [ipl::general -ip $ip -display_name "AXI SPI Engine AXIS Reorder ADI"]
set ip [ipl::general -ip $ip -supported_products {*}]
set ip [ipl::general -ip $ip -supported_platforms {esi radiant}]
set ip [ipl::general -ip $ip -href "https://analogdevicesinc.github.io/hdl/library/spi_engine/index.html#"]

set ip [ipl::add_interface -ip $ip \
    -inst_name m_axis \
    -display_name m_axis \
    -description m_axis \
    -master_slave master \
    -portmap { \
        {"m_axis_ready" "TREADY"} \
        {"m_axis_valid" "TVALID"} \
        {"m_axis_data" "TDATA"}
    } \
    -vlnv {amba.com:AMBA4:AXI4Stream:r0p0}]

set ip [ipl::add_interface -ip $ip \
    -inst_name s_axis \
    -display_name s_axis \
    -description s_axis \
    -master_slave slave \
    -portmap { \
        {"s_axis_ready" "TREADY"} \
        {"s_axis_valid" "TVALID"} \
        {"s_axis_data" "TDATA"}
    } \
    -vlnv {amba.com:AMBA4:AXI4Stream:r0p0}]

set ip [ipl::add_ip_files -ip $ip -dpath rtl -flist [list \
    "spi_axis_reorder.v" ]]

set ip [ipl::set_parameter -ip $ip \
    -id NUM_OF_LANES \
    -type param \
    -value_type int \
    -conn_mod spi_axis_reorder \
    -title {Num Of Lanes} \
    -default 2 \
    -output_formatter nostr \
    -group1 {General Configuration} \
    -group2 Config]

ipl::generate_ip $ip
