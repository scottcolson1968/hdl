###############################################################################
## Copyright (C) 2020-2025 Analog Devices, Inc. All rights reserved.
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
source ../../../scripts/adi_env.tcl
source ../../scripts/adi_ip_intel.tcl

ad_ip_create spi_engine_interconnect {SPI Engine Interconnect} p_elaboration
ad_ip_files spi_engine_interconnect [list\
  spi_engine_interconnect.v]

# parameters

ad_ip_parameter DATA_WIDTH INTEGER 8
ad_ip_parameter NUM_OF_SDI INTEGER 1

proc p_elaboration {} {

  set data_width [get_parameter_value DATA_WIDTH]
  set num_of_sdi [get_parameter_value NUM_OF_SDI]

  # clock and reset interface

  ad_interface clock    clk     input 1
  ad_interface reset-n  resetn  input 1 if_clk

  # interconnect direction interface

  add_interface s_interconnect_ctrl conduit end
  add_interface_port s_interconnect_ctrl interconnect_dir interconnect_dir input 1
  set_interface_property s_interconnect_ctrl associatedClock if_clk
  set_interface_property s_interconnect_ctrl associatedReset if_resetn

  # command master interface

  add_interface m_cmd axi4stream start
  add_interface_port m_cmd m_cmd_ready tready input  1
  add_interface_port m_cmd m_cmd_valid tvalid output 1
  add_interface_port m_cmd m_cmd_data  tdata  output 16

  set_interface_property m_cmd associatedClock if_clk
  set_interface_property m_cmd associatedReset if_resetn

  # SDO data master interface

  add_interface m_sdo axi4stream start
  add_interface_port m_sdo m_sdo_ready tready input  1
  add_interface_port m_sdo m_sdo_valid tvalid output 1
  add_interface_port m_sdo m_sdo_data  tdata  output $data_width

  set_interface_property m_sdo associatedClock if_clk
  set_interface_property m_sdo associatedReset if_resetn

  # SDI data master interface

  add_interface m_sdi axi4stream end
  add_interface_port m_sdi m_sdi_ready tready output 1
  add_interface_port m_sdi m_sdi_valid tvalid input  1
  add_interface_port m_sdi m_sdi_data  tdata  input  [expr $num_of_sdi * $data_width]

  set_interface_property m_sdi associatedClock if_clk
  set_interface_property m_sdi associatedReset if_resetn

  # SYNC master interface

  add_interface m_sync axi4stream end
  add_interface_port m_sync m_sync_valid tvalid input  1
  add_interface_port m_sync m_sync_ready tready output 1
  add_interface_port m_sync m_sync       tdata  input  8

  set_interface_property m_sync associatedClock if_clk
  set_interface_property m_sync associatedReset if_resetn

  # command slave0 interface

  add_interface s0_cmd axi4stream end
  add_interface_port s0_cmd s0_cmd_ready tready output 1
  add_interface_port s0_cmd s0_cmd_valid tvalid input  1
  add_interface_port s0_cmd s0_cmd_data  tdata  input  16

  set_interface_property s0_cmd associatedClock if_clk
  set_interface_property s0_cmd associatedReset if_resetn

  # SDO data slave0 interface

  add_interface s0_sdo axi4stream end
  add_interface_port s0_sdo s0_sdo_ready tready output 1
  add_interface_port s0_sdo s0_sdo_valid tvalid input  1
  add_interface_port s0_sdo s0_sdo_data  tdata  input  $data_width

  set_interface_property s0_sdo associatedClock if_clk
  set_interface_property s0_sdo associatedReset if_resetn

  # SDI data slave0 interface

  add_interface s0_sdi axi4stream start
  add_interface_port s0_sdi s0_sdi_ready tready input  1
  add_interface_port s0_sdi s0_sdi_valid tvalid output 1
  add_interface_port s0_sdi s0_sdi_data  tdata  output [expr $num_of_sdi * $data_width]

  set_interface_property s0_sdi associatedClock if_clk
  set_interface_property s0_sdi associatedReset if_resetn

  # SYNC slave0 interface

  add_interface s0_sync axi4stream start
  add_interface_port s0_sync s0_sync_valid tvalid output 1
  add_interface_port s0_sync s0_sync_ready tready input  1
  add_interface_port s0_sync s0_sync       tdata  output 8

  set_interface_property s0_sync associatedClock if_clk
  set_interface_property s0_sync associatedReset if_resetn

  # command slave1 interface

  add_interface s1_cmd axi4stream end
  add_interface_port s1_cmd s1_cmd_ready tready output 1
  add_interface_port s1_cmd s1_cmd_valid tvalid input  1
  add_interface_port s1_cmd s1_cmd_data  tdata  input  16

  set_interface_property s1_cmd associatedClock if_clk
  set_interface_property s1_cmd associatedReset if_resetn

  # SDO data slave1 interface

  add_interface s1_sdo axi4stream end
  add_interface_port s1_sdo s1_sdo_ready tready output 1
  add_interface_port s1_sdo s1_sdo_valid tvalid input  1
  add_interface_port s1_sdo s1_sdo_data  tdata  input  $data_width

  set_interface_property s1_sdo associatedClock if_clk
  set_interface_property s1_sdo associatedReset if_resetn

  # SDI data slave1 interface

  add_interface s1_sdi axi4stream start
  add_interface_port s1_sdi s1_sdi_ready tready input  1
  add_interface_port s1_sdi s1_sdi_valid tvalid output 1
  add_interface_port s1_sdi s1_sdi_data  tdata  output [expr $num_of_sdi * $data_width]

  set_interface_property s1_sdi associatedClock if_clk
  set_interface_property s1_sdi associatedReset if_resetn

  # SYNC slave1 interface

  add_interface s1_sync axi4stream start
  add_interface_port s1_sync s1_sync_valid tvalid output 1
  add_interface_port s1_sync s1_sync_ready tready input  1
  add_interface_port s1_sync s1_sync       tdata  output 8

  set_interface_property s1_sync associatedClock if_clk
  set_interface_property s1_sync associatedReset if_resetn

}

