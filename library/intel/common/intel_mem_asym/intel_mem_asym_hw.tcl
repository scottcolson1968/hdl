###############################################################################
## Copyright (C) 2019-2023 Analog Devices, Inc. All rights reserved.
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

source ../../../../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_intel.tcl

ad_ip_create intel_mem_asym {Intel Asymmetric Memory}
set_module_property COMPOSITION_CALLBACK p_intel_mem_asym

# parameters

ad_ip_parameter DEVICE_FAMILY STRING {Arria 10}
ad_ip_parameter A_ADDRESS_WIDTH INTEGER 8
ad_ip_parameter A_DATA_WIDTH INTEGER 512
ad_ip_parameter B_ADDRESS_WIDTH INTEGER 8
ad_ip_parameter B_DATA_WIDTH INTEGER 64

# compose

proc p_intel_mem_asym {} {

  set m_addr_width_a [get_parameter_value "A_ADDRESS_WIDTH"]
  set m_data_width_a [get_parameter_value "A_DATA_WIDTH"]
  set m_addr_width_b [get_parameter_value "B_ADDRESS_WIDTH"]
  set m_data_width_b [get_parameter_value "B_DATA_WIDTH"]

  set m_size [expr ((2**$m_addr_width_a)*$m_data_width_a)]
  if {$m_addr_width_a == 0} {
    set m_size [expr ((2**$m_addr_width_b)*$m_data_width_b)]
  }

  add_instance intel_mem ram_2port
  set_instance_parameter_value intel_mem {GUI_MODE} 0
  set_instance_parameter_value intel_mem {GUI_MEM_IN_BITS} 1
  set_instance_parameter_value intel_mem {GUI_MEMSIZE_BITS} $m_size
  set_instance_parameter_value intel_mem {GUI_VAR_WIDTH} 1
  set_instance_parameter_value intel_mem {GUI_QA_WIDTH} $m_data_width_a
  set_instance_parameter_value intel_mem {GUI_DATAA_WIDTH} $m_data_width_a
  set_instance_parameter_value intel_mem {GUI_QB_WIDTH} $m_data_width_b
  set_instance_parameter_value intel_mem {GUI_READ_OUTPUT_QB} {false}
  set_instance_parameter_value intel_mem {GUI_RAM_BLOCK_TYPE} {M20K}
  set_instance_parameter_value intel_mem {GUI_CLOCK_TYPE} 1

  add_interface mem_i_wrclock   clock   end
  add_interface mem_i_wren      conduit end
  add_interface mem_i_wraddress conduit end
  add_interface mem_i_datain    conduit end
  add_interface mem_i_rdclock   clock   end
  add_interface mem_i_rdaddress conduit end
  add_interface mem_o_dataout   conduit end

  set_interface_property mem_i_wrclock   EXPORT_OF intel_mem.wrclock
  set_interface_property mem_i_wren      EXPORT_OF intel_mem.wren
  set_interface_property mem_i_wraddress EXPORT_OF intel_mem.wraddress
  set_interface_property mem_i_datain    EXPORT_OF intel_mem.data
  set_interface_property mem_i_rdclock   EXPORT_OF intel_mem.rdclock
  set_interface_property mem_i_rdaddress EXPORT_OF intel_mem.rdaddress
  set_interface_property mem_o_dataout   EXPORT_OF intel_mem.q
}

