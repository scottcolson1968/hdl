####################################################################################
## Copyright (c) 2018 - 2025 Analog Devices, Inc.
### SPDX short identifier: BSD-1-Clause
## Wildcat2 : EVAL-AD4080-FMC on Digilent Genesys ZU-5EV.
## Modeled on projects/ad738x_fmc/genesys_zu5ev/Makefile.
####################################################################################

PROJECT_NAME := ad4080_fmc_evb_genesys_zu5ev

M_DEPS += system_top.v
M_DEPS += system_constr.xdc
M_DEPS += system_bd.tcl
M_DEPS += ../common/ad4080_fmc_evb_bd.tcl
M_DEPS += ../../scripts/adi_pd.tcl
M_DEPS += ../../common/genesys-zu5ev/genesys_zu5ev_system_constr.xdc
M_DEPS += ../../common/genesys-zu5ev/genesys_zu5ev_system_bd.tcl

# AD4080 LVDS capture datapath
LIB_DEPS += axi_ad408x
LIB_DEPS += axi_clock_monitor
LIB_DEPS += axi_dmac
LIB_DEPS += axi_sysid
LIB_DEPS += sysid_rom

# Backhaul reused from the Wildcat (ad738x) Genesys ZU port
LIB_DEPS += axi_clkgen

include ../../scripts/project-xilinx.mk
