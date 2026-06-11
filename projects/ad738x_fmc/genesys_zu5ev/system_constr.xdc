###############################################################################
## Copyright (C) 2019-2025 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################
## EVAL-AD738x FMC on Genesys ZU-5EV FMC LPC connector (bank 65, VADJ).
## IOSTANDARD assumes VADJ = 1.8 V; verify the board's VADJ rail before
## connecting hardware (AD7380 VIO supports 1.71 V min).

set_property -dict {PACKAGE_PIN L7  IOSTANDARD LVCMOS18 IOB TRUE} [get_ports spi_sclk];        ## G6  FMC_LA00_CC_P  IO_L13P_T2L_N0_GC_QBC_65
set_property -dict {PACKAGE_PIN J6  IOSTANDARD LVCMOS18 IOB TRUE} [get_ports spi_sdo];         ## H7  FMC_LA02_P     IO_L20P_T3L_N2_AD1P_65
set_property -dict {PACKAGE_PIN L6  IOSTANDARD LVCMOS18 IOB TRUE} [get_ports spi_cs];          ## G7  FMC_LA00_CC_N  IO_L13N_T2L_N1_GC_QBC_65

# rename auto-generated clock for SPIEngine to spi_clk - 160MHz
# NOTE: pl_clk0 ($sys_cpu_clk) is the only clock reaching the MMCM input,
# so no -master_clock disambiguation is required (on ZynqMP it is clk_pl_0).
create_generated_clock -name spi_clk -source [get_pins -filter name=~*CLKIN1 -of [get_cells -hier -filter name=~*spi_clkgen*i_mmcm]] [get_pins -filter name=~*CLKOUT0 -of [get_cells -hier -filter name=~*spi_clkgen*i_mmcm]]

# relax the SDO path to help closing timing at high frequencies
set_multicycle_path -setup 8 -to [get_cells -hierarchical -filter {NAME=~*/data_sdo_shift_reg[*]}] -from [get_clocks spi_clk]
set_multicycle_path -hold  7 -to [get_cells -hierarchical -filter {NAME=~*/data_sdo_shift_reg[*]}] -from [get_clocks spi_clk]
set_multicycle_path -setup 8 -to [get_cells -hierarchical -filter {NAME=~*/spi_ad738x_adc_execution/inst/left_aligned_reg*}] -from [get_clocks spi_clk]
set_multicycle_path -hold  7 -to [get_cells -hierarchical -filter {NAME=~*/spi_ad738x_adc_execution/inst/left_aligned_reg*}] -from [get_clocks spi_clk]
