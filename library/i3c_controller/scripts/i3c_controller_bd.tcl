###############################################################################
## Copyright (C) 2024-2025 Analog Devices, Inc. All rights reserved.
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

proc i3c_controller_create {{name "i3c_controller"} {async_clk 0} {i2c_mod 0} {offload 1} {max_devs 16}} {

  create_bd_cell -type hier $name
  current_bd_instance /$name

  if {$async_clk == 1} {
    create_bd_pin -dir I -type clk aclk
  }
  create_bd_pin -dir I -type clk clk
  create_bd_pin -dir I -type rst reset_n
  create_bd_pin -dir O irq
  create_bd_intf_pin -mode Master -vlnv analog.com:interface:i3c_controller_rtl:1.0 m_i3c
  if {$offload == 1} {
    create_bd_pin -dir I trigger
    create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 offload_sdi
  }

  ad_ip_instance i3c_controller_host_interface host_interface
  ad_ip_parameter host_interface CONFIG.ASYNC_CLK $async_clk
  ad_ip_parameter host_interface CONFIG.OFFLOAD $offload

  ad_ip_instance i3c_controller_core core
  ad_ip_parameter core CONFIG.MAX_DEVS $max_devs
  ad_ip_parameter core CONFIG.i2c_MOD $i2c_mod

  ad_connect clk host_interface/s_axi_aclk
  if {$async_clk == 1} {
    ad_connect aclk host_interface/clk
    ad_connect aclk core/clk
  } else {
    ad_connect clk core/clk
  }
  if {$offload == 1} {
    ad_connect trigger host_interface/offload_trigger
    ad_connect host_interface/offload_sdi offload_sdi
  }

  ad_connect core/i3c m_i3c
  ad_connect host_interface/reset_n core/reset_n
  ad_connect host_interface/rmap core/rmap
  ad_connect host_interface/cmdp core/cmdp
  ad_connect host_interface/sdio core/sdio

  ad_connect reset_n host_interface/s_axi_aresetn
  ad_connect irq     host_interface/irq

  current_bd_instance /
}
