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

create_bd_port -dir I ref_clk_125
create_bd_port -dir O reset

create_bd_port -dir O -from 1 -to 0 -type data speed_mode_a
create_bd_port -dir O -from 1 -to 0 -type data speed_mode_b

ad_ip_instance gmii_to_rgmii gmii_to_rgmii_0
ad_ip_parameter gmii_to_rgmii_0 CONFIG.SupportLevel Include_Shared_Logic_in_Core

# 200MHz for 7 series; 375 for ultrascale
ad_ip_instance clk_wiz clk_wiz
ad_ip_parameter clk_wiz CONFIG.PRIM_IN_FREQ 125
ad_ip_parameter clk_wiz CONFIG.MMCM_CLKIN1_PERIOD 8.000
ad_ip_parameter clk_wiz CONFIG.CLKOUT1_REQUESTED_OUT_FREQ 375
ad_ip_parameter clk_wiz CONFIG.PRIM_SOURCE "No_buffer"

make_bd_intf_pins_external  [get_bd_intf_pins gmii_to_rgmii_0/MDIO_PHY]
make_bd_intf_pins_external  [get_bd_intf_pins gmii_to_rgmii_0/RGMII]

ad_ip_instance proc_sys_reset proc_rgmii_reset

ad_connect gmii_to_rgmii_0/clkin clk_wiz/clk_out1

ad_connect ref_clk_125 clk_wiz/clk_in1
ad_connect sys_rstgen/peripheral_reset clk_wiz/reset
ad_connect proc_rgmii_reset/ext_reset_in sys_rstgen/peripheral_reset

ad_connect reset proc_rgmii_reset/peripheral_reset

ad_connect proc_rgmii_reset/dcm_locked clk_wiz/locked
ad_connect proc_rgmii_reset/slowest_sync_clk clk_wiz/clk_out1
ad_connect proc_rgmii_reset/peripheral_reset gmii_to_rgmii_0/tx_reset
ad_connect gmii_to_rgmii_0/rx_reset proc_rgmii_reset/peripheral_reset

make_bd_pins_external  [get_bd_pins gmii_to_rgmii_0/clock_speed]

ad_ip_instance gmii_to_rgmii gmii_to_rgmii_1
ad_ip_parameter gmii_to_rgmii_1 CONFIG.SupportLevel {Include_Shared_Logic_in_Example_Design}

make_bd_intf_pins_external  [get_bd_intf_pins gmii_to_rgmii_1/MDIO_PHY]
make_bd_intf_pins_external  [get_bd_intf_pins gmii_to_rgmii_1/RGMII]

ad_connect gmii_to_rgmii_1/ref_clk_in       gmii_to_rgmii_0/ref_clk_out
ad_connect gmii_to_rgmii_1/mmcm_locked_in   gmii_to_rgmii_0/mmcm_locked_out
ad_connect gmii_to_rgmii_1/gmii_clk_125m_in gmii_to_rgmii_0/gmii_clk_125m_out
ad_connect gmii_to_rgmii_1/gmii_clk_25m_in  gmii_to_rgmii_0/gmii_clk_25m_out
ad_connect gmii_to_rgmii_1/gmii_clk_2_5m_in gmii_to_rgmii_0/gmii_clk_2_5m_out

ad_connect proc_rgmii_reset/peripheral_reset gmii_to_rgmii_1/tx_reset
ad_connect gmii_to_rgmii_1/rx_reset proc_rgmii_reset/peripheral_reset

ad_connect gmii_to_rgmii_0/speed_mode speed_mode_a
ad_connect gmii_to_rgmii_1/speed_mode speed_mode_b
