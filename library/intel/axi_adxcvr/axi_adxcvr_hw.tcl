###############################################################################
## Copyright (C) 2016-2025 Analog Devices, Inc. All rights reserved.
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
package require quartus::device

source ../../../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_intel.tcl

set_module_property NAME axi_adxcvr
set_module_property DESCRIPTION "AXI ADXCVR Core"
set_module_property VERSION 1.0
set_module_property GROUP "Analog Devices"
set_module_property DISPLAY_NAME axi_adxcvr
set_module_property ELABORATION_CALLBACK p_axi_adxcvr
set_module_property VALIDATION_CALLBACK info_param_validate

# files

ad_ip_files axi_adxcvr [list \
  $ad_hdl_dir/library/util_cdc/sync_bits.v \
  $ad_hdl_dir/library/common/up_axi.v \
  axi_adxcvr_up.v \
  axi_adxcvr.v \
]

# parameters

add_parameter ID INTEGER 0
set_parameter_property ID DISPLAY_NAME ID
set_parameter_property ID UNITS None
set_parameter_property ID HDL_PARAMETER true

add_parameter TX_OR_RX_N INTEGER 0
set_parameter_property TX_OR_RX_N DISPLAY_NAME TX_OR_RX_N
set_parameter_property TX_OR_RX_N UNITS None
set_parameter_property TX_OR_RX_N HDL_PARAMETER true

add_parameter NUM_OF_LANES INTEGER 4
set_parameter_property NUM_OF_LANES DISPLAY_NAME NUM_OF_LANES
set_parameter_property NUM_OF_LANES UNITS None
set_parameter_property NUM_OF_LANES HDL_PARAMETER true

adi_add_auto_fpga_spec_params

adi_add_device_spec_param XCVR_TYPE
adi_add_device_spec_param FPGA_VOLTAGE
set_parameter_property FPGA_VOLTAGE DISPLAY_UNITS mV
set_parameter_property FPGA_VOLTAGE_MANUAL DISPLAY_UNITS mV
adi_add_indep_spec_params_overwrite XCVR_TYPE
adi_add_indep_spec_params_overwrite FPGA_VOLTAGE

# axi4 slave interface

ad_ip_intf_s_axi s_axi_aclk s_axi_aresetn 12

# xcvr interface

ad_interface reset up_rst output 1 s_axi_clock
set_interface_property if_up_rst associatedResetSinks s_axi_reset

# name changes

proc p_axi_adxcvr {} {

  set fpga_technology [get_parameter_value FPGA_TECHNOLOGY]
  set m_tx_or_rx_n [get_parameter_value TX_OR_RX_N]
  set m_num_of_lanes [get_parameter_value NUM_OF_LANES]

  if {$m_tx_or_rx_n} {
    set rx_tx "tx"
  } else {
    set rx_tx "rx"
  }

  # 105 = Agilex, see adi_intel_device_info_enc.tcl
  if {$fpga_technology == 105} {
    add_interface ready conduit end
    add_interface_port ready up_ready ${rx_tx}_ready input 1

    add_interface reset conduit start
    add_interface_port reset xcvr_reset ${rx_tx}_reset output 1

    add_interface reset_ack conduit end
    add_interface_port reset_ack up_reset_ack ${rx_tx}_reset_ack input 1

    if {$m_tx_or_rx_n == 0} {
      add_interface rx_lockedtodata conduit end
      add_interface_port rx_lockedtodata up_rx_lockedtodata rx_is_lockedtodata input $m_num_of_lanes
    } else {
      add_interface core_pll_locked conduit end
      add_interface_port core_pll_locked up_pll_locked ${rx_tx}_pll_locked Input $m_num_of_lanes
    }

  } else {

    add_interface core_pll_locked conduit end
    add_interface_port core_pll_locked up_pll_locked pll_locked Input 1

    if {$m_tx_or_rx_n == 1} {
      add_interface ready conduit end
      add_interface_port ready up_ready tx_ready input $m_num_of_lanes
    }

    if {$m_tx_or_rx_n == 0} {
      add_interface ready conduit end
      add_interface_port ready up_ready rx_ready input $m_num_of_lanes
    }
  }
}
