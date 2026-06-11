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

set mod_data [ipl::parse_module ./spi_engine_execution.v]
set ip $::ipl::ip

set ip [ipl::add_ports_from_module -ip $ip -mod_data $mod_data]

set ip [ipl::general \
    -vlnv "analog.com:ip:spi_engine_execution:1.0" \
    -category "ADI" \
    -keywords "ADI IP" \
    -min_radiant_version "2023.2" \
    -min_esi_version "2023.2" -ip $ip]

set ip [ipl::general -ip $ip -display_name "AXI SPI Engine execution ADI"]
set ip [ipl::general -ip $ip -supported_products {*}]
set ip [ipl::general -ip $ip -supported_platforms {esi radiant}]
set ip [ipl::general -ip $ip -href "https://analogdevicesinc.github.io/hdl/library/spi_engine/spi_engine_execution.html#spi-engine-execution"]

set ip [ipl::add_interface -ip $ip \
    -inst_name spi_engine_ctrl \
    -display_name spi_engine_ctrl \
    -description spi_engine_ctrl \
    -master_slave slave \
    -portmap { \
        {"cmd_ready" "CMD_READY"} \
        {"cmd_valid" "CMD_VALID"} \
        {"cmd" "CMD_DATA"} \
        {"sdo_data_ready" "SDO_READY"} \
        {"sdo_data_valid" "SDO_VALID"} \
        {"sdo_data" "SDO_DATA"} \
        {"sdi_data_ready" "SDI_READY"} \
        {"sdi_data_valid" "SDI_VALID"} \
        {"sdi_data" "SDI_DATA"} \
        {"sync_ready" "SYNC_READY"} \
        {"sync_valid" "SYNC_VALID"} \
        {"sync" "SYNC_DATA"} \
    } \
    -vlnv {analog.com:ADI:spi_engine_ctrl:1.0}]
set ip [ipl::add_interface -ip $ip \
    -inst_name spi_master \
    -display_name spi_master \
    -description spi_master \
    -master_slave master \
    -portmap { \
        {"sclk" "SCLK"} \
        {"sdi" "SDI"} \
        {"sdo" "SDO"} \
        {"sdo_t" "SDO_T"} \
        {"three_wire" "THREE_WIRE"} \
        {"cs" "CS"} \
    } \
    -vlnv {analog.com:ADI:spi_master:1.0}]

set ip [ipl::add_ip_files -ip $ip -dpath rtl -flist [list \
    "spi_engine_execution.v" \
    "spi_engine_execution_shiftreg.v" ]]

set ip [ipl::set_parameter -ip $ip \
    -id DATA_WIDTH \
    -type param \
    -value_type int \
    -conn_mod spi_engine_execution \
    -title {Parallel data width} \
    -default 8 \
    -output_formatter nostr \
    -value_range {(8, 32)} \
    -group1 {General Configuration} \
    -group2 Config]
set ip [ipl::set_parameter -ip $ip \
    -id NUM_OF_CS \
    -type param \
    -value_type int \
    -conn_mod spi_engine_execution \
    -title {Number of CSN lines} \
    -default 1 \
    -output_formatter nostr \
    -value_range {(1, 8)} \
    -group1 {General Configuration} \
    -group2 Config]
set ip [ipl::set_parameter -ip $ip \
    -id NUM_OF_SDI \
    -type param \
    -value_type int \
    -conn_mod spi_engine_execution \
    -title {Number of MISO} \
    -default 1 \
    -output_formatter nostr \
    -value_range {(1, 8)} \
    -group1 {General Configuration} \
    -group2 Config]

set ip [ipl::set_parameter -ip $ip \
    -id DEFAULT_SPI_CFG \
    -type param \
    -value_type int \
    -conn_mod spi_engine_execution \
    -title {Default SPI mode} \
    -default 0 \
    -options {[0, 1, 2, 3]} \
    -output_formatter nostr \
    -group1 {SPI Configuration} \
    -group2 Config]
set ip [ipl::set_parameter -ip $ip \
    -id DEFAULT_CLK_DIV \
    -type param \
    -value_type int \
    -conn_mod spi_engine_execution \
    -title {Default SCLK divider} \
    -default 0 \
    -output_formatter nostr \
    -value_range {(0, 255)} \
    -group1 {SPI Configuration} \
    -group2 Config]

set ip [ipl::set_parameter -ip $ip \
    -id SDI_DELAY \
    -type param \
    -value_type int \
    -conn_mod spi_engine_execution \
    -title {Delay MISO latching} \
    -default 0 \
    -options {[(True, 1), (False, 0)]} \
    -output_formatter nostr \
    -group1 {MOSI/MISO Configuration} \
    -group2 Config]
set ip [ipl::set_parameter -ip $ip \
    -id SDO_DEFAULT \
    -type param \
    -value_type int \
    -conn_mod spi_engine_execution \
    -title {MOSI default level} \
    -default 0 \
    -options {[0, 1]} \
    -output_formatter nostr \
    -group1 {MOSI/MISO Configuration} \
    -group2 Config]

set ip [ipl::set_parameter -ip $ip \
    -id ECHO_SCLK \
    -type param \
    -value_type int \
    -conn_mod spi_engine_execution \
    -title {Echoed SCLK} \
    -default 0 \
    -options {[(True, 1), (False, 0)]} \
    -output_formatter nostr \
    -group1 {Custom clocking options} \
    -group2 Config]

set ip [ipl::ignore_ports -ip $ip \
    -portlist {echo_sclk} \
    -expression {(ECHO_SCLK != 1)}]

ipl::generate_ip $ip
