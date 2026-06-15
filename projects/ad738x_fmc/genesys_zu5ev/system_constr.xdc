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

## 10G SFP+ (GTH bank 224 ch3 via high-speed mux; RM 7.3 + schematic)
## GT lane/refclk LOCs are set by the xxv_ethernet IP (Quad_X0Y1, lane X0Y7,
## MGTREFCLK0_224 = Y6/Y5). Only the refclk package pins are pinned here.
set_property PACKAGE_PIN Y6 [get_ports gt_refclk_p]
set_property PACKAGE_PIN Y5 [get_ports gt_refclk_n]
create_clock -period 6.400 -name gt_refclk [get_ports gt_refclk_p]

## SFP low-speed control (bank 44, pulled up on-board)
set_property -dict {PACKAGE_PIN AD14 IOSTANDARD LVCMOS33} [get_ports sfp_mod_detect]
set_property -dict {PACKAGE_PIN W13  IOSTANDARD LVCMOS33} [get_ports sfp_rs0]
set_property -dict {PACKAGE_PIN Y14  IOSTANDARD LVCMOS33} [get_ports sfp_rs1]
set_property -dict {PACKAGE_PIN W14  IOSTANDARD LVCMOS33} [get_ports sfp_rx_los]
set_property -dict {PACKAGE_PIN AB13 IOSTANDARD LVCMOS33} [get_ports sfp_tx_disable]
set_property -dict {PACKAGE_PIN AA13 IOSTANDARD LVCMOS33} [get_ports sfp_tx_fault]

## GTH lane mux: 1 = SFP, 0 = FMC GBT (bank 45)
set_property -dict {PACKAGE_PIN D10 IOSTANDARD LVCMOS18} [get_ports sel_sfp_not_fmc]
