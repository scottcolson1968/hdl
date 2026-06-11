###############################################################################
## Copyright (C) 2024 Analog Devices, Inc. All rights reserved.
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

proc ad_plddr_data_offload_create {data_offload_name} {

  upvar ad_hdl_dir ad_hdl_dir

  ad_ip_instance proc_sys_reset axi_rstgen
  ad_ip_instance mig_7series axi_ddr_cntrl
  file copy -force $ad_hdl_dir/projects/common/zc706/zc706_plddr3_mig.prj [get_property IP_DIR \
    [get_ips [get_property CONFIG.Component_Name [get_bd_cells axi_ddr_cntrl]]]]
  ad_ip_parameter axi_ddr_cntrl CONFIG.XML_INPUT_FILE zc706_plddr3_mig.prj

  # PL-DDR data offload interfaces
  create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 sys_clk
  create_bd_port -dir I -type rst sys_rst
  set_property CONFIG.POLARITY ACTIVE_HIGH [get_bd_ports sys_rst]
  create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 ddr3

  ad_connect axi_ddr_cntrl/ui_clk axi_rstgen/slowest_sync_clk
  ad_connect axi_ddr_cntrl/ui_clk $data_offload_name/storage_unit/m_axi_aclk
  ad_connect axi_ddr_cntrl/S_AXI $data_offload_name/storage_unit/MAXI_0
  ad_connect axi_rstgen/peripheral_aresetn $data_offload_name/storage_unit/m_axi_aresetn
  ad_connect axi_rstgen/peripheral_aresetn axi_ddr_cntrl/aresetn
  ad_connect sys_cpu_resetn axi_rstgen/ext_reset_in

  assign_bd_address [get_bd_addr_segs -of_objects [get_bd_cells axi_ddr_cntrl]]

  ad_connect  sys_rst axi_ddr_cntrl/sys_rst
  ad_connect  sys_clk axi_ddr_cntrl/SYS_CLK
  ad_connect  ddr3    axi_ddr_cntrl/DDR3
  ad_connect  axi_ddr_cntrl/device_temp_i GND
  ad_connect  $data_offload_name/i_data_offload/ddr_calib_done axi_ddr_cntrl/init_calib_complete

  ad_ip_parameter $data_offload_name/storage_unit CONFIG.DDR_BASE_ADDDRESS [format "%d" 0x80000000]

}
