###############################################################################
## Copyright (C) 2021-2023 Analog Devices, Inc. All rights reserved.
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
# These two reference clocks are connect to the same source on the PCB
create_clock -name refclk         -period  4.00 [get_ports fpga_clk_m2c_p[0]]
create_clock -name refclk_replica -period  4.00 [get_ports fpga_clk_m2c_0_replica_n]

# rx device clock
create_clock -name rx_device_clk     -period  4.00 [get_ports fpga_clk_m2c_p[1]]
# tx device clock
create_clock -name tx_device_clk     -period  4.00 [get_ports fpga_clk_m2c_p[2]]

# SPI 2 clock
create_generated_clock -name spi_2_clk  \
  -source [get_pins i_system_wrapper/system_i/axi_spi_2/ext_spi_clk] \
  -divide_by 2 [get_pins i_system_wrapper/system_i/axi_spi_2/sck_o]

# Constraint SYSREFs
# Assumption is that REFCLK and SYSREF have similar propagation delay,
# and the SYSREF is a source synchronous Edge-Aligned signal to REFCLK
set_input_delay -clock [get_clocks rx_device_clk] \
  [get_property PERIOD [get_clocks rx_device_clk]] \
  [get_ports {fpga_sysref_m2c_*}]
set_input_delay -clock [get_clocks tx_device_clk] -add_delay\
  [get_property PERIOD [get_clocks tx_device_clk]] \
  [get_ports {fpga_sysref_m2c_*}]
set_clock_groups -group rx_device_clk -group tx_device_clk -asynchronous

