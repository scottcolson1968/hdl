###############################################################################
## Copyright (C) 2017-2023 Analog Devices, Inc. All rights reserved.
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

# gpio (pmods)

set_property  -dict {PACKAGE_PIN  P17   IOSTANDARD LVCMOS25} [get_ports gpio_bd[8]]   ; ## PMOD2_3_LS
set_property  -dict {PACKAGE_PIN  P18   IOSTANDARD LVCMOS25} [get_ports gpio_bd[9]]   ; ## PMOD2_2_LS
set_property  -dict {PACKAGE_PIN  W10   IOSTANDARD LVCMOS25} [get_ports gpio_bd[10]]  ; ## PMOD2_1_LS
set_property  -dict {PACKAGE_PIN  V7    IOSTANDARD LVCMOS25} [get_ports gpio_bd[11]]  ; ## PMOD2_0_LS
set_property  -dict {PACKAGE_PIN  E15   IOSTANDARD LVCMOS25} [get_ports gpio_bd[12]]  ; ## PMOD1_0_LS
set_property  -dict {PACKAGE_PIN  D15   IOSTANDARD LVCMOS25} [get_ports gpio_bd[13]]  ; ## PMOD1_1_LS
set_property  -dict {PACKAGE_PIN  W17   IOSTANDARD LVCMOS25} [get_ports gpio_bd[14]]  ; ## PMOD1_2_LS
set_property  -dict {PACKAGE_PIN  W5    IOSTANDARD LVCMOS25} [get_ports gpio_bd[15]]  ; ## PMOD1_3_LS

