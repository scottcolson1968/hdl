###############################################################################
## Asynchronous 4.096 MSPS ADC trigger (replicates the reference design).
##
## Decouples the sample RATE from SCLK so we can run SCLK at the in-spec 80 MHz
## (spi_clk = 160 MHz) AND trigger at exactly 4.096 MSPS:
##   pl_clk0 (100 MHz) -> clk_wiz_4096 (102.4 MHz) -> fit_timer_4096 (/25)
##   -> 4.096 MHz interrupt -> spi_ad738x_adc/trigger
## The offload is set to asynchronous core-clock + asynchronous trigger, so the
## 4.096 MHz trigger is independent of the 160 MHz spi_clk domain.
##
## Sourced from build_gui_build.tcl AFTER adc_en_gpio.tcl.
###############################################################################

# 1) offload: asynchronous core clock + asynchronous trigger
set_property -dict [list \
  CONFIG.ASYNC_SPI_CLK {true} \
  CONFIG.ASYNC_TRIG {true} \
] [get_bd_cells spi_ad738x_adc/spi_ad738x_adc_offload]

# 2) clk_wiz: 100 MHz (pl_clk0 / sys_cpu_clk) -> 102.4 MHz
create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_4096
set_property -dict [list \
  CONFIG.PRIM_IN_FREQ {100.000} \
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {102.4} \
  CONFIG.RESET_TYPE {ACTIVE_LOW} \
] [get_bd_cells clk_wiz_4096]
connect_bd_net -net sys_cpu_clk    [get_bd_pins clk_wiz_4096/clk_in1]
connect_bd_net -net sys_cpu_resetn [get_bd_pins clk_wiz_4096/resetn]

# 3) fit_timer: 102.4 MHz / 25 = 4.096 MHz interrupt
create_bd_cell -type ip -vlnv xilinx.com:ip:fit_timer:2.0 fit_timer_4096
set_property -dict [list CONFIG.C_NO_CLOCKS {25}] [get_bd_cells fit_timer_4096]
connect_bd_net [get_bd_pins clk_wiz_4096/clk_out1] [get_bd_pins fit_timer_4096/Clk]

# 4) rewire the trigger: drop the cnv_gate/pwm path, drive from the fit_timer
disconnect_bd_net [get_bd_nets cnv_gate_Res] [get_bd_pins spi_ad738x_adc/trigger]
connect_bd_net [get_bd_pins fit_timer_4096/Interrupt] [get_bd_pins spi_ad738x_adc/trigger]

validate_bd_design
puts "ASYNC-4096: clk_wiz_4096(102.4MHz) -> fit_timer_4096(/25 = 4.096MHz) -> spi_ad738x_adc/trigger; offload ASYNC_SPI_CLK+ASYNC_TRIG=true"
