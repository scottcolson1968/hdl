###############################################################################
## Copyright (C) 2022-2023 Analog Devices, Inc. All rights reserved.
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

package require qsys
source ../../scripts/adi_env.tcl
source ../scripts/adi_ip_intel.tcl

set_module_property NAME axi_ad7768
set_module_property DESCRIPTION "AXI AD7768 IP core"
set_module_property VERSION 1.0
set_module_property GROUP "Analog Devices"
set_module_property DISPLAY_NAME axi_ad7768
set_module_property ELABORATION_CALLBACK create_ports
# source files

ad_ip_files axi_ad7768 [list \
  "$ad_hdl_dir/library/common/ad_rst.v" \
  "$ad_hdl_dir/library/common/up_adc_channel.v" \
  "$ad_hdl_dir/library/common/up_adc_common.v" \
  "$ad_hdl_dir/library/common/up_axi.v" \
  "$ad_hdl_dir/library/common/up_clock_mon.v" \
  "$ad_hdl_dir/library/common/up_xfer_cntrl.v" \
  "$ad_hdl_dir/library/common/up_xfer_status.v" \
  "axi_ad7768_if.v" \
  "axi_ad7768.v"]

# IP parameters

add_parameter ID INTEGER 0
set_parameter_property ID DEFAULT_VALUE 0
set_parameter_property ID DISPLAY_NAME "ID"
set_parameter_property ID UNITS None
set_parameter_property ID HDL_PARAMETER true


set group "General Configuration"

ad_ip_parameter NUM_CHANNELS INTEGER 8 true [list \
  DISPLAY_NAME "Number of channels" \
  DISPLAY_UNITS "channels" \
  ALLOWED_RANGES {4 8} \
  GROUP $group \
]

# AXI4 Memory Mapped Interface

ad_ip_intf_s_axi s_axi_aclk s_axi_aresetn 15

# ad7768_if and axi_gpreg ports

ad_interface signal adc_dovf            input  1 ovf
ad_interface signal clk_in              input  1
ad_interface signal ready_in            input  1
ad_interface signal data_in             input  8

ad_interface reset  adc_reset           output 1 
ad_interface clock  adc_clk             output  1
ad_interface signal adc_sync            output  1 sync
ad_interface signal adc_valid           output  1  valid
ad_interface signal adc_data            output  32 data

set_interface_property if_adc_reset associatedClock if_adc_clk

proc create_ports {} {
set num_channels [get_parameter_value "NUM_CHANNELS"]
set samples_per_channel 1
set sample_data_width 32
set channel_data_width [expr $sample_data_width * $samples_per_channel]

for {set n 0} {$n < $num_channels} {incr n} {
add_interface adc_ch_$n conduit end
add_interface_port adc_ch_$n adc_enable_$n enable Output 1
add_interface_port adc_ch_$n adc_data_$n data Output $sample_data_width
add_interface_port adc_ch_$n adc_valid_$n valid Output 1
set_interface_property adc_ch_$n associatedClock if_adc_clk 
set_interface_property adc_ch_$n associatedReset none
}

}

