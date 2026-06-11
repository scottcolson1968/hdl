###############################################################################
## Copyright (C) 2024-2025 Analog Devices, Inc. All rights reserved.
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
#################################################################################

# ip

package require qsys 14.0
source ../../scripts/adi_env.tcl
source ../scripts/adi_ip_intel.tcl

ad_ip_create util_sigma_delta_spi {UTIL SIGMA DELTA SPI}
set_module_property ELABORATION_CALLBACK p_elaboration
ad_ip_files util_sigma_delta_spi [list \
  util_sigma_delta_spi.v]

# parameters

ad_ip_parameter IDLE_TIMEOUT INTEGER 63
ad_ip_parameter CS_PIN INTEGER 0
ad_ip_parameter NUM_OF_CS INTEGER 2

proc p_elaboration {} {

  set num_cs [get_parameter_value NUM_OF_CS]
# interfaces

# clock and reset interface

  ad_interface clock    clk    input 1
  ad_interface reset-n  resetn input 1 if_clk

  ad_interface signal data_ready output 1 if_pwm

  ad_interface clock s_sclk   input 1 sclk
  ad_interface signal s_sdo   input 1 sdo
  ad_interface signal s_sdo_t input 1 sdo_t
  ad_interface signal s_sdi   output 1 sdi
  ad_interface signal s_cs    input $num_cs cs

  ad_interface clock m_sclk   output 1
  ad_interface signal m_sdo   output 1
  ad_interface signal m_sdo_t output 1
  ad_interface signal m_sdi   input 1
  ad_interface signal m_cs    output $num_cs
}
