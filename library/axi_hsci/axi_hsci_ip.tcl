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

# ip

source ../../scripts/adi_env.tcl
source ../scripts/adi_ip_xilinx.tcl

adi_ip_create axi_hsci
adi_ip_files axi_hsci [list \
  "../common/ad_rst.v" \
  "../xilinx/common/ad_rst_constr.xdc" \
  "axi_hsci.sv" \
  "hsci_master_axi_slave.sv" \
  "hsci_master_logic.sv" \
  "hsci_master_regs_defs.vh" \
  "hsci_master_regs_regs.sv" \
  "hsci_master_top.sv" \
  "hsci_mcore.v" \
  "hsci_mdec.sv" \
  "hsci_menc.sv" \
  "hsci_mfrm_det.v" \
  "hsci_mlink_ctrl.sv" \
  "lfsr15_8.v" \
  "pulse_sync.v" \
  "axi4_lite.sv" ]

adi_ip_properties axi_hsci
adi_ip_ttcl axi_hsci "axi_hsci_constr.ttcl"
set_property display_name "ADI AXI HSCI" [ipx::current_core]
set_property description "ADI AXI HSCI" [ipx::current_core]
# set_property company_url {https://wiki.analog.com/resources/fpga/docs/axi_hsci} [ipx::current_core]

adi_init_bd_tcl

proc add_reset {name polarity} {
  set reset_intf [ipx::infer_bus_interface $name xilinx.com:signal:reset_rtl:1.0 [ipx::current_core]]
  set reset_polarity [ipx::add_bus_parameter "POLARITY" $reset_intf]
  set_property value $polarity $reset_polarity
}

ipx::infer_bus_interface hsci_pclk xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
# ipx::infer_bus_interface hsci_data_clk xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::infer_bus_interface s_axi_aclk xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
# ipx::infer_bus_interface delay_clk xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]

add_reset s_axi_aresetn ACTIVE_LOW

ipx::add_bus_parameter ASSOCIATED_BUSIF [ipx::get_bus_interfaces s_axi_aclk -of_objects [ipx::current_core]]
set_property value s_axi [ipx::get_bus_parameters ASSOCIATED_BUSIF -of_objects [ipx::get_bus_interfaces s_axi_aclk -of_objects [ipx::current_core]]]

adi_add_auto_fpga_spec_params
ipx::create_xgui_files [ipx::current_core]

ipx::save_core [ipx::current_core]
