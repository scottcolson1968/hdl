###############################################################################
## Copyright (C) 2025 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################

set_property -dict {PACKAGE_PIN H4  IOSTANDARD LVCMOS18 IOB TRUE} [get_ports spi_sdia]; ## D8  FMC_LA01_CC_P  IO_L7P_T1L_N0_QBC_AD13P_65
set_property -dict {PACKAGE_PIN H3  IOSTANDARD LVCMOS18} [get_ports spi_sdib];  ## D9  FMC_LA01_CC_N  IO_L7N_T1L_N1_QBC_AD13N_65
set_property -dict {PACKAGE_PIN K4  IOSTANDARD LVCMOS18} [get_ports spi_sdid];  ## G9  FMC_LA03_P     IO_L11P_T1U_N8_GC_65
