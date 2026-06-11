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

adi_ip_instance -vlnv {latticesemi.com:sim_model:clk_rst_gen:1.0.0} \
    -meta_vlnv {latticesemi.com:sim_model:Clock_Reset_Generator:1.0.0} \
    -cfg_value {TB_CLK_PERIOD:8} \
    -ip_iname "clk_rst_gen_inst"
adi_ip_instance -vlnv {latticesemi.com:sim_model:uart:1.0.0} \
    -meta_vlnv {latticesemi.com:sim_model:UART_Model:1.0.0} \
    -cfg_value {CLK_MHZ:125} \
    -ip_iname "uart_inst"

sbp_connect_net ${project_name}_v/uart_inst/clk \
    ${project_name}_v/clk_rst_gen_inst/tb_clk_o
sbp_connect_net -name ${project_name}_v/clk_rst_gen_inst_tb_clk_o_net \
    ${project_name}_v/dut_inst/clk_125
sbp_connect_net ${project_name}_v/uart_inst/rstn \
    ${project_name}_v/clk_rst_gen_inst/tb_rst_o
sbp_connect_net -name ${project_name}_v/clk_rst_gen_inst_tb_rst_o_net \
    ${project_name}_v/dut_inst/rstn_i
sbp_connect_net ${project_name}_v/dut_inst/rxd_i \
    ${project_name}_v/uart_inst/uart_txd
sbp_connect_net ${project_name}_v/dut_inst/txd_o \
    ${project_name}_v/uart_inst/uart_rxd
