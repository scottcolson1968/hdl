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

package require qsys

source ../../../../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_intel.tcl

ad_ip_create jesd204_f_tile_adapter_tx "ADI JESD204C F-Tile PHY Adapter TX"

# parameters

ad_ip_parameter DEVICE STRING "Agilex 7" false

# files

ad_ip_files jesd204_f_tile_adapter_tx [list \
  $ad_hdl_dir/library/util_cdc/sync_bits.v \
  gearbox_66b64b.v \
  jesd204_f_tile_adapter_tx.v \
  jesd204_f_tile_adapter_tx_constr.sdc \
]

# clock

add_interface phy_tx_clock clock end
add_interface_port phy_tx_clock o_clk clk Input 1

add_interface link_clock clock end
add_interface_port link_clock i_clk clk Input 1

# interfaces

# link layer -> adapter
add_interface link_tx conduit end
add_interface_port link_tx i_phy_data char Input 64
add_interface_port link_tx i_phy_header header Input 2
add_interface_port link_tx i_phy_charisk charisk Input 8

add_interface reset reset end
set_interface_property reset associatedClock link_clock
set_interface_property reset synchronousEdges DEASSERT
add_interface_port reset i_reset reset Input 1

# adapter -> transceiver
add_interface phy_tx_parallel_data conduit end
add_interface_port phy_tx_parallel_data o_phy_data raw_data Output 80

# adapter -> cdc fifo

add_interface fifo_input conduit end
add_interface_port fifo_input wr_clk  wrclk  Output 1
add_interface_port fifo_input wr_en   wrreq  Output 1
add_interface_port fifo_input wr_data datain Output 66
add_interface_port fifo_input rd_clk  rdclk  Output 1
add_interface_port fifo_input rd_en   rdreq  Output 1
add_interface_port fifo_input aclr    aclr   Output 1

# cdc fifo -> adapter

add_interface fifo_output conduit end
add_interface_port fifo_output rd_data  dataout Input 66
add_interface_port fifo_output rd_empty rdempty Input 1
add_interface_port fifo_output wr_full  wrfull  Input 1
