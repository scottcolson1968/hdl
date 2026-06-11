###############################################################################
## Copyright (C) 2015-2023 Analog Devices, Inc. All rights reserved.
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

package require qsys 14.0
source ../../scripts/adi_env.tcl
source ../scripts/adi_ip_intel.tcl

ad_ip_create util_adcfifo {UTIL ADC FIFO IP core}
set_module_property ELABORATION_CALLBACK p_util_adcfifo

# files

ad_ip_files util_adcfifo [list\
  $ad_hdl_dir/library/common/ad_rst.v \
  $ad_hdl_dir/library/common/ad_axis_inf_rx.v \
  $ad_hdl_dir/library/util_cdc/sync_gray.v \
  util_adcfifo.v \
  util_adcfifo_constr.sdc]

# parameters

ad_ip_parameter DEVICE_FAMILY STRING {Arria 10}
ad_ip_parameter FPGA_TECHNOLOGY INTEGER 1
ad_ip_parameter ADC_DATA_WIDTH INTEGER 256
ad_ip_parameter DMA_DATA_WIDTH INTEGER 64
ad_ip_parameter DMA_READY_ENABLE INTEGER 1
ad_ip_parameter DMA_ADDRESS_WIDTH INTEGER 10

# elaborate

proc p_util_adcfifo {} {

  # read parameters

  set m_device_family [get_parameter_value "DEVICE_FAMILY"]
  set m_adc_data_width [get_parameter_value "ADC_DATA_WIDTH"]
  set m_dma_addr_width [get_parameter_value "DMA_ADDRESS_WIDTH"]
  set m_dma_data_width [get_parameter_value "DMA_DATA_WIDTH"]

  # intel memory

  add_hdl_instance mem_asym intel_mem_asym 1.0
  set_instance_parameter_value mem_asym DEVICE_FAMILY $m_device_family
  set_instance_parameter_value mem_asym A_ADDRESS_WIDTH 0
  set_instance_parameter_value mem_asym A_DATA_WIDTH $m_adc_data_width
  set_instance_parameter_value mem_asym B_ADDRESS_WIDTH $m_dma_addr_width
  set_instance_parameter_value mem_asym B_DATA_WIDTH $m_dma_data_width

  # interfaces

  ad_interface clock  adc_clk   input  1
  ad_interface reset  adc_rst   input  1              if_adc_clk
  ad_interface signal adc_wr    input  1              valid
  ad_interface signal adc_wdata input  ADC_DATA_WIDTH data
  ad_interface signal adc_wovf  output 1              ovf

  ad_interface clock  dma_clk         input  1 clk
  ad_interface signal dma_xfer_req    input  1 xfer_req
  ad_interface signal dma_xfer_status output 4 xfer_status

  add_interface m_axis axi4stream start
  set_interface_property m_axis associatedClock if_dma_clk
  set_interface_property m_axis associatedReset if_adc_rst
  add_interface_port m_axis  dma_wr     tvalid Output 1
  add_interface_port m_axis  dma_wready tready Input  1
  add_interface_port m_axis  dma_wdata  tdata  Output DMA_DATA_WIDTH

}

