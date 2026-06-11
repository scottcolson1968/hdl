###############################################################################
## Copyright (C) 2019-2024 Analog Devices, Inc. All rights reserved.
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

# constraints

# gpio 

set_property  -dict {PACKAGE_PIN  D20   IOSTANDARD LVCMOS33} [get_ports btn[0]]       ; ## BTN0
set_property  -dict {PACKAGE_PIN  D19   IOSTANDARD LVCMOS33} [get_ports btn[1]]       ; ## BTN1
set_property  -dict {PACKAGE_PIN  L15   IOSTANDARD LVCMOS33} [get_ports led[0]]       ; ## LED0_B
set_property  -dict {PACKAGE_PIN  N15   IOSTANDARD LVCMOS33} [get_ports led[1]]       ; ## LED0_R
set_property  -dict {PACKAGE_PIN  G17   IOSTANDARD LVCMOS33} [get_ports led[2]]       ; ## LED0_G
set_property  -dict {PACKAGE_PIN  G14   IOSTANDARD LVCMOS33} [get_ports led[3]]       ; ## LED1_B
set_property  -dict {PACKAGE_PIN  L14   IOSTANDARD LVCMOS33} [get_ports led[4]]       ; ## LED1_R
set_property  -dict {PACKAGE_PIN  M15   IOSTANDARD LVCMOS33} [get_ports led[5]]       ; ## LED1_G

# iic

set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS33} [get_ports iic_ard_scl] ; ## Arduino_SCL
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports iic_ard_sda] ; ## Arduino_SDA
