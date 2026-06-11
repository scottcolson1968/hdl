###############################################################################
## Copyright (C) 2025 Analog Devices, Inc. All rights reserved.
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

source $ad_hdl_dir/library/i3c_controller/scripts/i3c_controller_qsys.tcl

# disable I2C1

set_instance_parameter_value sys_hps {I2C1_Mode} {N/A}
set_instance_parameter_value sys_hps {I2C1_PinMuxing} {Unused}

set async_clk 0
set i2c_mod 4
set offload $ad_project_params(OFFLOAD)
set max_devs 16

i3c_controller_create i3c $async_clk $i2c_mod $offload $max_devs

if {$offload} {
  # axi pwm gen

  add_instance i3c_offload_pwm axi_pwm_gen
  set_instance_parameter_value i3c_offload_pwm {N_PWMS} {1}
  set_instance_parameter_value i3c_offload_pwm {PULSE_0_PERIOD} {120}
  set_instance_parameter_value i3c_offload_pwm {PULSE_0_WIDTH} {1}

  # receive dma

  add_instance i3c_offload_dma axi_dmac
  set_instance_parameter_value i3c_offload_dma {DMA_TYPE_SRC} {1}
  set_instance_parameter_value i3c_offload_dma {DMA_TYPE_DEST} {0}
  set_instance_parameter_value i3c_offload_dma {AXI_SLICE_SRC} {0}
  set_instance_parameter_value i3c_offload_dma {AXI_SLICE_DEST} {1}
  set_instance_parameter_value i3c_offload_dma {DMA_DATA_WIDTH_SRC} {32}
  set_instance_parameter_value i3c_offload_dma {DMA_DATA_WIDTH_DEST} {64}
}

# clocks

add_connection sys_clk.clk i3c_host_interface.s_axi_clock
add_connection sys_clk.clk i3c_core.if_clk
if {$offload} {
  add_connection sys_clk.clk i3c_offload_dma.s_axi_clock
  add_connection sys_clk.clk i3c_offload_dma.if_s_axis_aclk
  add_connection sys_clk.clk i3c_offload_dma.m_dest_axi_clock
  add_connection sys_clk.clk i3c_offload_pwm.s_axi_clock
  add_connection sys_clk.clk i3c_offload_pwm.if_ext_clk
}

# resets

add_connection sys_clk.clk_reset i3c_host_interface.s_axi_reset
if {$offload} {
  add_connection sys_clk.clk_reset i3c_offload_dma.s_axi_reset
  add_connection sys_clk.clk_reset i3c_offload_dma.m_dest_axi_reset
  add_connection sys_clk.clk_reset i3c_offload_pwm.s_axi_reset
}

# interfaces

if {$offload} {
  add_connection i3c_host_interface.offload_sdi i3c_offload_dma.s_axis
  add_connection i3c_offload_pwm.if_pwm_0 i3c_host_interface.if_offload_trigger
}

# exported interface

set_interface_property i3c EXPORT_OF i3c_core.i3c

# cpu interconnects

ad_cpu_interconnect 0x00030000 i3c_host_interface.s_axi
if {$offload} {
  ad_cpu_interconnect 0x00020000 i3c_offload_dma.s_axi
  ad_cpu_interconnect 0x00040000 i3c_offload_pwm.s_axi
}

# dma interconnect

if {$offload} {
  ad_dma_interconnect i3c_offload_dma.m_dest_axi
}

# interrupts

if {$offload} {
  ad_cpu_interrupt 4 i3c_offload_dma.interrupt_sender
}
ad_cpu_interrupt 5 i3c_host_interface.interrupt_sender
