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

# Primary clock definitions

# Set clocks depending on the requested LANE_RATE paramter from the util_adxcvr block
# Maximum values for Link clock:
# 204B - 15.5 Gbps /40 = 387.5MHz
# 204C - 24.75 Gbps /66 = 375MHz
set jesd_mode [dict get [dict get [get_property QUAD0_PROT0_SETTINGS [get_cells i_system_wrapper/system_i/jesd204_phy/xcvr/inst]] LR0_SETTINGS] INTERNAL_PRESET]
set link_mode [expr {$jesd_mode=="JESD204_64B66B" ? 2:1}]

set rx_lane_rate [dict get [dict get [get_property QUAD0_PROT0_SETTINGS [get_cells i_system_wrapper/system_i/jesd204_phy/xcvr/inst]] LR0_SETTINGS] RX_LINE_RATE]
set tx_lane_rate [dict get [dict get [get_property QUAD0_PROT1_SETTINGS [get_cells i_system_wrapper/system_i/jesd204_phy/xcvr/inst]] LR0_SETTINGS] TX_LINE_RATE]

set rx_link_clk [expr $rx_lane_rate*1000/[expr {$link_mode==2?66:40}]]
set tx_link_clk [expr $tx_lane_rate*1000/[expr {$link_mode==2?66:40}]]

set rx_link_clk_period [expr 1000/$rx_link_clk]
set tx_link_clk_period [expr 1000/$tx_link_clk]

set rx_ll_width   [get_property DATA_PATH_WIDTH     [get_cells i_system_wrapper/system_i/axi_apollo_rx_jesd/rx/inst]]
set tx_ll_width   [get_property DATA_PATH_WIDTH     [get_cells i_system_wrapper/system_i/axi_apollo_tx_jesd/tx/inst]]
set rx_tpl_width  [get_property TPL_DATA_PATH_WIDTH [get_cells i_system_wrapper/system_i/axi_apollo_rx_jesd/rx/inst]]
set tx_tpl_width  [get_property TPL_DATA_PATH_WIDTH [get_cells i_system_wrapper/system_i/axi_apollo_tx_jesd/tx/inst]]

set rx_device_clk [expr $rx_link_clk*$rx_ll_width/$rx_tpl_width]
set tx_device_clk [expr $tx_link_clk*$tx_ll_width/$tx_tpl_width]
set rx_device_clk_period [expr 1000/$rx_device_clk]
set tx_device_clk_period [expr 1000/$tx_device_clk]

# refclk and refclk_replica are connect to the same source on the PCB
# Set reference clock to same frequency as the link clock,
# this will ease the XCVR out clocks propagation calculation.
# TODO: this restricts RX_LANE_RATE=TX_LANE_RATE
create_clock -name refclk0 -period  $rx_link_clk_period [get_ports ref_clk_p]

# device clock
create_clock -name rx_device_clk     -period  $rx_device_clk_period [get_ports clk_m2c_p[0]]
create_clock -name tx_device_clk     -period  $tx_device_clk_period [get_ports clk_m2c_p[1]]

# Constraint SYSREFs
# Assumption is that REFCLK and SYSREF have similar propagation delay,
# and the SYSREF is a source synchronous Edge-Aligned signal to REFCLK
set_input_delay -clock [get_clocks rx_device_clk] \
  [get_property PERIOD [get_clocks rx_device_clk]] \
  [get_ports {sysref_in*}]
set_input_delay -clock [get_clocks tx_device_clk] -add_delay\
  [get_property PERIOD [get_clocks tx_device_clk]] \
  [get_ports {sysref_in*}]

set_clock_groups -group rx_device_clk -group tx_device_clk -asynchronous
