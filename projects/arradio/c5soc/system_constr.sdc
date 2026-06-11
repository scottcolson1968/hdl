###############################################################################
## Copyright (C) 2014-2023 Analog Devices, Inc. All rights reserved.
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

create_clock -period "20.000 ns" -name sys_clk  [get_ports {sys_clk}]
create_clock -period 4.0 -name rx_clk [get_ports {rx_clk_in}]

derive_pll_clocks
derive_clock_uncertainty

create_clock -period 4.0 -name v_rx_clk
create_generated_clock -name v_tx_clk -source [get_ports {rx_clk_in}] [get_ports {tx_clk_out}]

set_input_delay -add_delay -rise -max  1.2  -clock {v_rx_clk} [get_ports {rx_frame_in}]
set_input_delay -add_delay -rise -max  1.2  -clock {v_rx_clk} [get_ports {rx_data_in[0]}]
set_input_delay -add_delay -rise -max  1.2  -clock {v_rx_clk} [get_ports {rx_data_in[1]}]
set_input_delay -add_delay -rise -max  1.2  -clock {v_rx_clk} [get_ports {rx_data_in[2]}]
set_input_delay -add_delay -rise -max  1.2  -clock {v_rx_clk} [get_ports {rx_data_in[3]}]
set_input_delay -add_delay -rise -max  1.2  -clock {v_rx_clk} [get_ports {rx_data_in[4]}]
set_input_delay -add_delay -rise -max  1.2  -clock {v_rx_clk} [get_ports {rx_data_in[5]}]
set_input_delay -add_delay -rise -min  0.2  -clock {v_rx_clk} [get_ports {rx_frame_in}]
set_input_delay -add_delay -rise -min  0.2  -clock {v_rx_clk} [get_ports {rx_data_in[0]}]
set_input_delay -add_delay -rise -min  0.2  -clock {v_rx_clk} [get_ports {rx_data_in[1]}]
set_input_delay -add_delay -rise -min  0.2  -clock {v_rx_clk} [get_ports {rx_data_in[2]}]
set_input_delay -add_delay -rise -min  0.2  -clock {v_rx_clk} [get_ports {rx_data_in[3]}]
set_input_delay -add_delay -rise -min  0.2  -clock {v_rx_clk} [get_ports {rx_data_in[4]}]
set_input_delay -add_delay -rise -min  0.2  -clock {v_rx_clk} [get_ports {rx_data_in[5]}]
set_input_delay -add_delay -fall -max  0.2  -clock {v_rx_clk} [get_ports {rx_frame_in}]
set_input_delay -add_delay -fall -max  0.2  -clock {v_rx_clk} [get_ports {rx_data_in[0]}]
set_input_delay -add_delay -fall -max  0.2  -clock {v_rx_clk} [get_ports {rx_data_in[1]}]
set_input_delay -add_delay -fall -max  0.2  -clock {v_rx_clk} [get_ports {rx_data_in[2]}]
set_input_delay -add_delay -fall -max  0.2  -clock {v_rx_clk} [get_ports {rx_data_in[3]}]
set_input_delay -add_delay -fall -max  0.2  -clock {v_rx_clk} [get_ports {rx_data_in[4]}]
set_input_delay -add_delay -fall -max  0.2  -clock {v_rx_clk} [get_ports {rx_data_in[5]}]
set_input_delay -add_delay -fall -min  0.2  -clock {v_rx_clk} [get_ports {rx_frame_in}]
set_input_delay -add_delay -fall -min  0.2  -clock {v_rx_clk} [get_ports {rx_data_in[0]}]
set_input_delay -add_delay -fall -min  0.2  -clock {v_rx_clk} [get_ports {rx_data_in[1]}]
set_input_delay -add_delay -fall -min  0.2  -clock {v_rx_clk} [get_ports {rx_data_in[2]}]
set_input_delay -add_delay -fall -min  0.2  -clock {v_rx_clk} [get_ports {rx_data_in[3]}]
set_input_delay -add_delay -fall -min  0.2  -clock {v_rx_clk} [get_ports {rx_data_in[4]}]
set_input_delay -add_delay -fall -min  0.2  -clock {v_rx_clk} [get_ports {rx_data_in[5]}]

set_output_delay -add_delay -rise -max  1.2 -clock {v_tx_clk} [get_ports {tx_frame_out}]
set_output_delay -add_delay -rise -max  1.2 -clock {v_tx_clk} [get_ports {tx_data_out[0]}]
set_output_delay -add_delay -rise -max  1.2 -clock {v_tx_clk} [get_ports {tx_data_out[1]}]
set_output_delay -add_delay -rise -max  1.2 -clock {v_tx_clk} [get_ports {tx_data_out[2]}]
set_output_delay -add_delay -rise -max  1.2 -clock {v_tx_clk} [get_ports {tx_data_out[3]}]
set_output_delay -add_delay -rise -max  1.2 -clock {v_tx_clk} [get_ports {tx_data_out[4]}]
set_output_delay -add_delay -rise -max  1.2 -clock {v_tx_clk} [get_ports {tx_data_out[5]}]
set_output_delay -add_delay -rise -min  0.2 -clock {v_tx_clk} [get_ports {tx_frame_out}]
set_output_delay -add_delay -rise -min  0.2 -clock {v_tx_clk} [get_ports {tx_data_out[0]}]
set_output_delay -add_delay -rise -min  0.2 -clock {v_tx_clk} [get_ports {tx_data_out[1]}]
set_output_delay -add_delay -rise -min  0.2 -clock {v_tx_clk} [get_ports {tx_data_out[2]}]
set_output_delay -add_delay -rise -min  0.2 -clock {v_tx_clk} [get_ports {tx_data_out[3]}]
set_output_delay -add_delay -rise -min  0.2 -clock {v_tx_clk} [get_ports {tx_data_out[4]}]
set_output_delay -add_delay -rise -min  0.2 -clock {v_tx_clk} [get_ports {tx_data_out[5]}]
set_output_delay -add_delay -fall -max  1.2 -clock {v_tx_clk} [get_ports {tx_frame_out}]
set_output_delay -add_delay -fall -max  1.2 -clock {v_tx_clk} [get_ports {tx_data_out[0]}]
set_output_delay -add_delay -fall -max  1.2 -clock {v_tx_clk} [get_ports {tx_data_out[1]}]
set_output_delay -add_delay -fall -max  1.2 -clock {v_tx_clk} [get_ports {tx_data_out[2]}]
set_output_delay -add_delay -fall -max  1.2 -clock {v_tx_clk} [get_ports {tx_data_out[3]}]
set_output_delay -add_delay -fall -max  1.2 -clock {v_tx_clk} [get_ports {tx_data_out[4]}]
set_output_delay -add_delay -fall -max  1.2 -clock {v_tx_clk} [get_ports {tx_data_out[5]}]
set_output_delay -add_delay -fall -min  0.2 -clock {v_tx_clk} [get_ports {tx_frame_out}]
set_output_delay -add_delay -fall -min  0.2 -clock {v_tx_clk} [get_ports {tx_data_out[0]}]
set_output_delay -add_delay -fall -min  0.2 -clock {v_tx_clk} [get_ports {tx_data_out[1]}]
set_output_delay -add_delay -fall -min  0.2 -clock {v_tx_clk} [get_ports {tx_data_out[2]}]
set_output_delay -add_delay -fall -min  0.2 -clock {v_tx_clk} [get_ports {tx_data_out[3]}]
set_output_delay -add_delay -fall -min  0.2 -clock {v_tx_clk} [get_ports {tx_data_out[4]}]
set_output_delay -add_delay -fall -min  0.2 -clock {v_tx_clk} [get_ports {tx_data_out[5]}]

# locked is async- most likely clock won't be running when deasserted

set_false_path  -to [get_registers *axi_ad9361_lvds_if:i_dev_if|up_drp_locked_m1*]

# frame reader seems to use the wrong reset!

set_false_path -from [get_registers *altera_reset_synchronizer:alt_rst_sync_uq1|altera_reset_synchronizer_int_chain_out*]

