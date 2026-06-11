###############################################################################
## Copyright (C) 2022-2025 Analog Devices, Inc. All rights reserved.
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

adi_ip_create util_do_ram
adi_ip_files util_do_ram [list \
  "../common/ad_mem_asym.v" \
  "../common/util_pipeline_stage.v" \
  "util_do_ram_constr.xdc" \
  "util_do_ram_ooc.ttcl" \
  "util_do_ram.v" \
]

adi_ip_properties_lite util_do_ram
adi_ip_ttcl util_do_ram "util_do_ram_ooc.ttcl"

set_property PROCESSING_ORDER LATE [ipx::get_files util_do_ram_constr.xdc \
  -of_objects [ipx::get_file_groups -of_objects [ipx::current_core] \
  -filter {NAME =~ *synthesis*}]]

adi_ip_add_core_dependencies { \
  analog.com:user:util_cdc:1.0 \
  analog.com:user:util_axis_fifo:1.0 \
}

set_property display_name "ADI Data Offload RAM Storage" [ipx::current_core]
set_property description "Serves as storage for the Data Offload core, using Block RAM or URAM" [ipx::current_core]

set cc [ipx::current_core]

adi_add_bus "s_axis" "slave" \
  "xilinx.com:interface:axis_rtl:1.0" \
  "xilinx.com:interface:axis:1.0" \
  [list {"s_axis_ready" "TREADY"} \
    {"s_axis_valid" "TVALID"} \
    {"s_axis_data" "TDATA"} \
    {"s_axis_strb" "TSTRB"} \
    {"s_axis_keep" "TKEEP"} \
    {"s_axis_user" "TUSER"} \
    {"s_axis_last" "TLAST"}]

adi_add_bus "m_axis" "master" \
  "xilinx.com:interface:axis_rtl:1.0" \
  "xilinx.com:interface:axis:1.0" \
  [list {"m_axis_ready" "TREADY"} \
    {"m_axis_valid" "TVALID"} \
    {"m_axis_data" "TDATA"} \
    {"m_axis_strb" "TSTRB"} \
    {"m_axis_keep" "TKEEP"} \
    {"m_axis_user" "TUSER"} \
    {"m_axis_last" "TLAST"}]

adi_add_bus "wr_ctrl" "slave" \
  "analog.com:interface:if_do_ctrl_rtl:1.0" \
  "analog.com:interface:if_do_ctrl:1.0" \
  [list {"wr_request_enable" "request_enable"} \
        {"wr_request_valid" "request_valid"} \
        {"wr_request_ready" "request_ready"} \
        {"wr_request_length" "request_length"} \
        {"wr_response_measured_length" "response_measured_length"} \
        {"wr_response_eot" "response_eot"} \
    ]

adi_add_bus "rd_ctrl" "slave" \
  "analog.com:interface:if_do_ctrl_rtl:1.0" \
  "analog.com:interface:if_do_ctrl:1.0" \
  [list {"rd_request_enable" "request_enable"} \
        {"rd_request_valid" "request_valid"} \
        {"rd_request_ready" "request_ready"} \
        {"rd_request_length" "request_length"} \
        {"rd_response_eot" "response_eot"} \
    ]

adi_add_bus_clock "s_axis_aclk" "s_axis:wr_ctrl" "s_axis_aresetn"
adi_add_bus_clock "m_axis_aclk" "m_axis:rd_ctrl" "m_axis_aresetn"

ipx::create_xgui_files [ipx::current_core]
ipx::save_core [ipx::current_core]
