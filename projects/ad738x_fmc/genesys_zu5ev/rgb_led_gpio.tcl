###############################################################################
## RGB status LED (LD5) AXI GPIO
##
## The PS EMIO GPIO output is only 3 bits wide (PSU__GPIO_EMIO_WIDTH=3) and all
## three are consumed by the green board LEDs, so there are no spare PS GPIO
## outputs for the RGB LED. Instead, drive LD5 from a dedicated 3-bit, all-
## outputs AXI GPIO whose gpio_io_o is brought out as an external BD port
## (rgb_led_o[2:0]) and wired to ld5_r/g/b in system_top.v.
##
## Controlled from Linux via leds-gpio "daq:red/green/blue" + daq-status-led
## .service (red=booting, blue=iiod starting, green=safe to connect).
##
## Sourced from build_gui_build.tcl AFTER adc_en_gpio.tcl (which used axi_smc
## M07 / NUM_MI 8); this adds M08 / NUM_MI 9 @ 0xA0080000.
###############################################################################

# 3-bit, all-outputs AXI GPIO (memory-mapped, controlled from the PS).
set rgb [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_rgb_led]
set_property -dict [list \
  CONFIG.C_ALL_OUTPUTS {1} \
  CONFIG.C_GPIO_WIDTH  {3} \
] $rgb

# Hang a new AXI-Lite master off axi_smc (M00..M07 used by adc_en -> add M08).
set_property CONFIG.NUM_MI {9} [get_bd_cells axi_smc]
connect_bd_intf_net [get_bd_intf_pins axi_smc/M08_AXI] \
                    [get_bd_intf_pins axi_gpio_rgb_led/S_AXI]

# Same AXI-Lite clock/reset domain as the other PL peripherals.
connect_bd_net -net sys_cpu_clk    [get_bd_pins axi_gpio_rgb_led/s_axi_aclk]
connect_bd_net -net sys_cpu_resetn [get_bd_pins axi_gpio_rgb_led/s_axi_aresetn]

# Bring the 3 output bits out as an external port -> system_top.v -> ld5 pins.
create_bd_port -dir O -from 2 -to 0 rgb_led_o
connect_bd_net [get_bd_pins axi_gpio_rgb_led/gpio_io_o] [get_bd_ports rgb_led_o]

# Address: next free slot after adc_en @0xA0070000.
assign_bd_address -offset 0xA0080000 -range 0x00010000 \
  -target_address_space [get_bd_addr_spaces sys_ps8/Data] \
  [get_bd_addr_segs axi_gpio_rgb_led/S_AXI/Reg] -force

validate_bd_design
puts "RGB-LED-GPIO: added axi_gpio_rgb_led @0xA0080000 -> rgb_led_o\[2:0\] -> ld5_r/g/b"
