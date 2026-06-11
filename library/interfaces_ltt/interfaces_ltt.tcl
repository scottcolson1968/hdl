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

source ../../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_lattice.tcl

set if [ipl::create_interface \
    -vlnv {analog.com:ADI:fifo_wr:1.0} \
    -directConnection true \
    -isAddressable false \
    -description "ADI fifo wr interface" \
    -ports {
        {-n DATA -d out -p required}
        {-n EN -d out -p required -w 1}
        {-n OVERFLOW -w 1 -p optional -d in}
        {-n SYNC -p optional -w 1 -d out}
        {-n XFER_REQ -p optional -w 1 -d in}
    }]
ipl::generate_interface $if

set if [ipl::create_interface \
    -vlnv {analog.com:ADI:fifo_rd:1.0} \
    -directConnection true \
    -isAddressable false \
    -description "ADI fifo rd interface" \
    -ports {
        {-n DATA -d in -p required}
        {-n EN -d out -p required -w 1}
        {-n UNDERFLOW -d in -p optional -w 1}
        {-n VALID -d in -p optional -w 1}
        {-n XFER_REQ -d in -p optional -w 1}
    }]
ipl::generate_interface $if

set if [ipl::create_interface \
    -vlnv {analog.com:ADI:spi_engine_ctrl:1.0} \
    -directConnection true \
    -isAddressable false \
    -description "ADI SPI Engine Control Interface" \
    -ports {
        {-n CMD_READY -p required -w 1 -d in}
        {-n CMD_VALID -p required -w 1 -d out}
        {-n CMD_DATA -p required -w 16 -d out}
        {-n SDO_READY -p required -w 1 -d in}
        {-n SDO_VALID -p required -w 1 -d out}
        {-n SDO_DATA -p required -d out}
        {-n SDI_READY -p required -w 1 -d out}
        {-n SDI_VALID -p required -w 1 -d in}
        {-n SDI_DATA -p required -d in}
        {-n SYNC_READY -p required -w 1 -d out}
        {-n SYNC_VALID -p required -w 1 -d in}
        {-n SYNC_DATA -p required -w 8 -d in}
    }]
ipl::generate_interface $if

set if [ipl::create_interface \
    -vlnv {analog.com:ADI:spi_engine_offload_ctrl:1.0} \
    -directConnection true \
    -isAddressable false \
    -description "ADI SPI Engine Offload Control Interface" \
    -ports {
        {-n CMD_WR_EN -p required -w 1 -d out}
        {-n CMD_WR_DATA -p required -w 16 -d out}
        {-n SDO_WR_EN -p required -w 1 -d out}
        {-n SDO_WR_DATA -p required -d out}
        {-n ENABLE -p required -w 1 -d out}
        {-n MEM_RESET -p required -w 1 -d out}
        {-n ENABLED -p required -w 1 -d in}
        {-n SYNC_READY -p required -w 1 -d out}
        {-n SYNC_VALID -p required -w 1 -d in}
        {-n SYNC_DATA -p required -w 8 -d in}
    }]
ipl::generate_interface $if

set if [ipl::create_interface \
    -vlnv {analog.com:ADI:spi_engine_interconnect_ctrl:1.0} \
    -directConnection true \
    -isAddressable false \
    -description "ADI SPI Engine Interconnect Control Interface" \
    -ports {
        {-n INTERCONNECT_DIR -p required -w 1 -d out}
    }]
ipl::generate_interface $if

set if [ipl::create_interface \
    -vlnv {analog.com:ADI:spi_master:1.0} \
    -directConnection true \
    -isAddressable false \
    -description "SPI Master Interface" \
    -ports {
        {-n SCLK -p optional -w 1 -d out}
        {-n SDI -p optional -d in}
        {-n SDO -p optional -w 1 -d out}
        {-n SDO_T -p optional -w 1 -d out}
        {-n THREE_WIRE -p optional -w 1 -d out}
        {-n CS -p optional -d out}
    }]
ipl::generate_interface $if

set if [ipl::create_interface \
    -vlnv {analog.com:ADI:if_framelock:1.0} \
    -directConnection true \
    -isAddressable false \
    -description "AXI DMA framelock Interface." \
    -ports {
        {-n s2m_framelock -p required -d in}
        {-n s2m_framelock_valid -p required -w 1 -d in}
        {-n m2s_framelock -p required -d out}
        {-n m2s_framelock_valid -p required -w 1 -d out}
    }]
ipl::generate_interface $if
