###############################################################################
## Copyright (C) 2016-2025 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################
## Digilent Genesys ZU-5EV board-level constraints.
## Pin locations from Digilent Genesys-ZU-5EV-D-Master.xdc.

# constraints
# gpio (switches, leds and such)

set_property  -dict {PACKAGE_PIN  AB14  IOSTANDARD LVCMOS33} [get_ports gpio_bd_i[0]]    ; ## SW0
set_property  -dict {PACKAGE_PIN  Y13   IOSTANDARD LVCMOS33} [get_ports gpio_bd_i[1]]    ; ## SW1
set_property  -dict {PACKAGE_PIN  W12   IOSTANDARD LVCMOS33} [get_ports gpio_bd_i[2]]    ; ## SW2
set_property  -dict {PACKAGE_PIN  AB15  IOSTANDARD LVCMOS33} [get_ports gpio_bd_i[3]]    ; ## SW3

set_property  -dict {PACKAGE_PIN  B10   IOSTANDARD LVCMOS18} [get_ports gpio_bd_i[4]]    ; ## BTN2
set_property  -dict {PACKAGE_PIN  H12   IOSTANDARD LVCMOS18} [get_ports gpio_bd_i[5]]    ; ## BTN3
set_property  -dict {PACKAGE_PIN  J12   IOSTANDARD LVCMOS18} [get_ports gpio_bd_i[6]]    ; ## BTN4
set_property  -dict {PACKAGE_PIN  F12   IOSTANDARD LVCMOS18} [get_ports gpio_bd_i[7]]    ; ## BTN5
set_property  -dict {PACKAGE_PIN  A12   IOSTANDARD LVCMOS18} [get_ports gpio_bd_i[8]]    ; ## BTN6

set_property  -dict {PACKAGE_PIN  L14   IOSTANDARD LVCMOS33} [get_ports gpio_bd_o[0]]    ; ## LD1
set_property  -dict {PACKAGE_PIN  L13   IOSTANDARD LVCMOS33} [get_ports gpio_bd_o[1]]    ; ## LD2
set_property  -dict {PACKAGE_PIN  K14   IOSTANDARD LVCMOS33} [get_ports gpio_bd_o[2]]    ; ## LD3
set_property  -dict {PACKAGE_PIN  J14   IOSTANDARD LVCMOS33} [get_ports gpio_bd_o[3]]    ; ## LD4

# VADJ request to the platform MCU: level pins sampled while VADJ_AUTO is low;
# VADJ stays disabled if VADJ_AUTO is high (Genesys ZU RM 10.2.1.1).

set_property  -dict {PACKAGE_PIN  AC14  IOSTANDARD LVCMOS33} [get_ports vadj_level[0]]   ; ## vadj_level[0]
set_property  -dict {PACKAGE_PIN  AC13  IOSTANDARD LVCMOS33} [get_ports vadj_level[1]]   ; ## vadj_level[1]
set_property  -dict {PACKAGE_PIN  G10   IOSTANDARD LVCMOS18} [get_ports vadj_auton]      ; ## vadj_auton

# Define SPI clock
create_clock -name spi0_clk      -period 40   [get_pins -hier */EMIOSPI0SCLKO]
create_clock -name spi1_clk      -period 40   [get_pins -hier */EMIOSPI1SCLKO]
