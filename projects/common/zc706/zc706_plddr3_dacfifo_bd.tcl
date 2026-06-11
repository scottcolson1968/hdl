###############################################################################
## Copyright (C) 2014-2023 Analog Devices, Inc. All rights reserved.
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

# pl ddr3 (use only when dma is not capable of keeping up).
# generic fifo interface - existence is oblivious to software.

proc ad_dacfifo_create {dac_fifo_name dac_data_width dac_dma_data_width dac_fifo_address_width} {

  upvar ad_hdl_dir ad_hdl_dir

  ad_ip_instance proc_sys_reset axi_rstgen
  ad_ip_instance mig_7series axi_ddr_cntrl

  file copy -force $ad_hdl_dir/projects/common/zc706/zc706_plddr3_mig.prj [get_property IP_DIR \
    [get_ips [get_property CONFIG.Component_Name [get_bd_cells axi_ddr_cntrl]]]]
  ad_ip_parameter axi_ddr_cntrl CONFIG.XML_INPUT_FILE zc706_plddr3_mig.prj

  create_bd_port -dir I -type rst sys_rst
  set_property CONFIG.POLARITY ACTIVE_HIGH [get_bd_ports sys_rst]

  create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 ddr3
  create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 sys_clk

  ad_connect  sys_rst axi_ddr_cntrl/sys_rst
  ad_connect  sys_clk axi_ddr_cntrl/SYS_CLK
  ad_connect  ddr3 axi_ddr_cntrl/DDR3

  ad_ip_instance axi_dacfifo $dac_fifo_name
  ad_ip_parameter $dac_fifo_name CONFIG.DAC_DATA_WIDTH $dac_data_width
  ad_ip_parameter $dac_fifo_name CONFIG.DMA_DATA_WIDTH $dac_dma_data_width
  ad_ip_parameter $dac_fifo_name CONFIG.AXI_DATA_WIDTH 512
  ad_ip_parameter $dac_fifo_name CONFIG.AXI_SIZE 6
  ad_ip_parameter $dac_fifo_name CONFIG.AXI_LENGTH 255
  ad_ip_parameter $dac_fifo_name CONFIG.AXI_ADDRESS 0x80000000
  ad_ip_parameter $dac_fifo_name CONFIG.AXI_ADDRESS_LIMIT 0xbfffffff

  ad_connect  axi_ddr_cntrl/S_AXI $dac_fifo_name/axi
  ad_connect  axi_ddr_cntrl/ui_clk $dac_fifo_name/axi_clk
  ad_connect  axi_ddr_cntrl/ui_clk axi_rstgen/slowest_sync_clk
  ad_connect  sys_cpu_resetn axi_rstgen/ext_reset_in
  ad_connect  axi_rstgen/peripheral_aresetn $dac_fifo_name/axi_resetn
  ad_connect  axi_rstgen/peripheral_aresetn axi_ddr_cntrl/aresetn
  ad_connect  axi_ddr_cntrl/device_temp_i GND

  assign_bd_address [get_bd_addr_segs -of_objects [get_bd_cells axi_ddr_cntrl]]

}
