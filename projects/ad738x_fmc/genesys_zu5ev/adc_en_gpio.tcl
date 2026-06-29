###############################################################################
## ADC "en" enable GPIO
##
## Adds a 1-bit, all-outputs AXI GPIO whose single output bit drives the
## axi_ad738x_dma "sync" (transfer-start) input. With SYNC_TRANSFER_START
## enabled, the DMA only begins a transfer once this bit is high, so the PS
## (via the IIO ad7380 driver's "start" gpio / "en" attribute) gates ADC
## acquisition.
##
## Sourced from build_gui_build.tcl AFTER `source system_bd_gui.tcl`, so it
## layers on top of the GUI-exported block design without editing that export.
##
## Mirrors the reference design (c:/share/ad738x_fmc/gzu_5ev): axi_gpio_1 ->
## axi_ad738x_dma/sync, SYNC_TRANSFER_START true. We do NOT replicate the
## reference's external gpio_io_o_0 pin (axi_gpio_0) -- the enable bit is
## internal to the DMA, so no system_top.v / XDC changes are required.
###############################################################################

# DMA must wait for the sync signal before starting each transfer.
# The dedicated "sync" BD pin only exists when SYNC_TRANSFER_START=1 AND
# AXIS_TUSER_SYNC=0 (otherwise transfer-start sync comes via the stream TUSER
# and no sync pin is exposed). Matches the reference axi_ad738x_dma config.
set_property -dict [list \
  CONFIG.SYNC_TRANSFER_START {true} \
  CONFIG.AXIS_TUSER_SYNC {false} \
] [get_bd_cells axi_ad738x_dma]

# 1-bit, all-outputs AXI GPIO (memory-mapped, controlled from the PS).
set adc_en_gpio [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_adc_en]
set_property -dict [list \
  CONFIG.C_ALL_OUTPUTS {1} \
  CONFIG.C_GPIO_WIDTH  {1} \
] $adc_en_gpio

# Hang a new AXI-Lite master off axi_smc (M00..M06 already used -> add M07).
set_property CONFIG.NUM_MI {8} [get_bd_cells axi_smc]
connect_bd_intf_net [get_bd_intf_pins axi_smc/M07_AXI] \
                    [get_bd_intf_pins axi_gpio_adc_en/S_AXI]

# Same AXI-Lite clock/reset domain as the other PL peripherals.
connect_bd_net -net sys_cpu_clk    [get_bd_pins axi_gpio_adc_en/s_axi_aclk]
connect_bd_net -net sys_cpu_resetn [get_bd_pins axi_gpio_adc_en/s_axi_aresetn]

# Drive the DMA transfer-start sync with the GPIO output bit ("en").
connect_bd_net [get_bd_pins axi_gpio_adc_en/gpio_io_o] \
               [get_bd_pins axi_ad738x_dma/sync]

# Address: next free LPD slot after xxv_eth @ 0xA0060000.
assign_bd_address -offset 0xA0070000 -range 0x00010000 \
  -target_address_space [get_bd_addr_spaces sys_ps8/Data] \
  [get_bd_addr_segs axi_gpio_adc_en/S_AXI/Reg] -force

validate_bd_design
puts "ADC-EN-GPIO: added axi_gpio_adc_en @0xA0070000 -> axi_ad738x_dma/sync (SYNC_TRANSFER_START=true)"
