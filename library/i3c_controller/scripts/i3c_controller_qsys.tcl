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
  add_instance ${name}_host_interface i3c_controller_host_interface

  set_instance_parameter_value ${name}_host_interface {ASYNC_CLK} $async_clk
  set_instance_parameter_value ${name}_host_interface {OFFLOAD}   $offload

  add_instance ${name}_core i3c_controller_core

  set_instance_parameter_value ${name}_core {MAX_DEVS} $max_devs
  set_instance_parameter_value ${name}_core {I2C_MOD} $i2c_mod

  add_connection ${name}_host_interface.sdo  ${name}_core.sdo
  add_connection ${name}_host_interface.cmdp ${name}_core.cmdp
  add_connection ${name}_host_interface.rmap ${name}_core.rmap
  add_connection ${name}_core.sdi ${name}_host_interface.sdi
  add_connection ${name}_core.ibi ${name}_host_interface.ibi

  add_connection ${name}_host_interface.if_reset_n ${name}_core.if_reset_n
}
