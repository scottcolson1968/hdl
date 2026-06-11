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

set mod_data [ipl::parse_module ./spi_engine_offload.v]
set ip $::ipl::ip

set ip [ipl::add_ports_from_module -ip $ip -mod_data $mod_data]

set ip [ipl::general \
    -vlnv "analog.com:ip:spi_engine_offload:1.0" \
    -category "ADI" \
    -keywords "ADI IP" \
    -min_radiant_version "2023.2" \
    -min_esi_version "2023.2" -ip $ip]
set ip [ipl::general -ip $ip -display_name "AXI SPI Engine Offload ADI"]
set ip [ipl::general -ip $ip -supported_products {*}]
set ip [ipl::general -ip $ip -supported_platforms {esi radiant}]
set ip [ipl::general -ip $ip -href "https://analogdevicesinc.github.io/hdl/library/spi_engine/spi_engine_offload.html"]

set ip [ipl::add_interface -ip $ip \
    -inst_name spi_engine_offload_ctrl \
    -display_name spi_engine_offload_ctrl \
    -description spi_engine_offload_ctrl \
    -master_slave slave \
    -portmap { \
        { "ctrl_cmd_wr_en" "CMD_WR_EN"} \
        { "ctrl_cmd_wr_data" "CMD_WR_DATA"} \
        { "ctrl_sdo_wr_en" "SDO_WR_EN"} \
        { "ctrl_sdo_wr_data" "SDO_WR_DATA"} \
        { "ctrl_enable" "ENABLE"} \
        { "ctrl_enabled" "ENABLED"} \
        { "ctrl_mem_reset" "MEM_RESET"} \
        { "status_sync_ready" "SYNC_READY"} \
        { "status_sync_valid" "SYNC_VALID"} \
        { "status_sync_data" "SYNC_DATA"} \
    } \
    -vlnv {analog.com:ADI:spi_engine_offload_ctrl:1.0}]

set ip [ipl::add_interface -ip $ip \
    -inst_name spi_engine_ctrl \
    -display_name spi_engine_ctrl \
    -description spi_engine_ctrl \
    -master_slave master \
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
        {"sync_data" "SYNC_DATA"} \
    } \
    -vlnv {analog.com:ADI:spi_engine_ctrl:1.0}]

set ip [ipl::add_interface -ip $ip \
    -inst_name m_interconnect_ctrl \
    -display_name m_interconnect_ctrl \
    -description spi_engine_interconnect_ctrl \
    -master_slave master \
    -portmap { \
        {"interconnect_dir" "INTERCONNECT_DIR"} \
    } \
    -vlnv {analog.com:ADI:spi_engine_interconnect_ctrl:1.0}]

set ip [ipl::add_interface -ip $ip \
    -inst_name offload_sdi \
    -display_name offload_sdi \
    -description offload_sdi \
    -master_slave master \
    -portmap { \
        {"offload_sdi_valid" "TVALID"} \
        {"offload_sdi_ready" "TREADY"} \
        {"offload_sdi_data" "TDATA"} \
    } \
    -vlnv {amba.com:AMBA4:AXI4Stream:r0p0}]

set ip [ipl::add_interface -ip $ip \
    -inst_name s_axis_sdo \
    -display_name s_axis_sdo \
    -description s_axis_sdo \
    -master_slave slave \
    -portmap { \
        {"s_axis_sdo_valid" "TVALID"} \
        {"s_axis_sdo_ready" "TREADY"} \
        {"s_axis_sdo_data" "TDATA"} \
    } \
    -vlnv {amba.com:AMBA4:AXI4Stream:r0p0}]

set ip [ipl::add_ip_files -ip $ip -dpath rtl -flist [list \
    "$ad_hdl_dir/library/util_cdc/sync_bits.v" \
    "$ad_hdl_dir/library/util_cdc/sync_event.v" \
    "spi_engine_offload.v" ]]

set ip [ipl::set_parameter -ip $ip \
    -id DATA_WIDTH \
    -type param \
    -value_type int \
    -conn_mod spi_engine_offload \
    -title {Shift register's data width} \
    -default 8 \
    -output_formatter nostr \
    -value_range {(8, 255)} \
    -group1 {General Configuration} \
    -group2 Config]
set ip [ipl::set_parameter -ip $ip \
    -id NUM_OF_SDI \
    -type param \
    -value_type int \
    -conn_mod spi_engine_offload \
    -title {Number of MISO lines} \
    -default 1 \
    -output_formatter nostr \
    -value_range {(1, 8)} \
    -group1 {General Configuration} \
    -group2 Config]
set ip [ipl::set_parameter -ip $ip \
    -id ASYNC_SPI_CLK \
    -type param \
    -value_type int \
    -conn_mod spi_engine_offload \
    -title {Asynchronous core clock} \
    -default 0 \
    -options {[(True, 1), (False, 0)]} \
    -output_formatter nostr \
    -group1 {General Configuration} \
    -group2 Config]
set ip [ipl::set_parameter -ip $ip \
    -id ASYNC_TRIG \
    -type param \
    -value_type int \
    -conn_mod spi_engine_offload \
    -title {Asynchronous trigger} \
    -default 0 \
    -options {[(True, 1), (False, 0)]} \
    -output_formatter nostr \
    -group1 {General Configuration} \
    -group2 Config]
set ip [ipl::set_parameter -ip $ip \
    -id SDO_STREAMING \
    -type param \
    -value_type int \
    -conn_mod spi_engine_offload \
    -title {SDO Streaming} \
    -default 0 \
    -options {[(True, 1), (False, 0)]} \
    -output_formatter nostr \
    -group1 {General Configuration} \
    -group2 Config]
set ip [ipl::ignore_ports_by_prefix -ip $ip \
    -mod_data $mod_data \
    -v_prefix s_axis_sdo \
    -expression {(SDO_STREAMING == 0)}]

set ip [ipl::set_parameter -ip $ip \
    -id CMD_MEM_ADDRESS_WIDTH \
    -type param \
    -value_type int \
    -conn_mod spi_engine_offload \
    -title {Command FIFO address width} \
    -default 4 \
    -output_formatter nostr \
    -value_range {(1, 16)} \
    -group1 {Command stream FIFO configuration} \
    -group2 Config]
set ip [ipl::set_parameter -ip $ip \
    -id SDO_MEM_ADDRESS_WIDTH \
    -type param \
    -value_type int \
    -conn_mod spi_engine_offload \
    -title {MOSI FIFO address width} \
    -default 4 \
    -output_formatter nostr \
    -value_range {(1, 16)} \
    -group1 {Command stream FIFO configuration} \
    -group2 Config]

ipl::generate_ip $ip
