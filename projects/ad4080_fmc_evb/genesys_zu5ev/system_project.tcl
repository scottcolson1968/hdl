###############################################################################
## Copyright (C) 2024-2025 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
## Wildcat2 : EVAL-AD4080-FMC on Digilent Genesys ZU-5EV.
## Modeled on projects/ad738x_fmc/genesys_zu5ev/system_project.tcl.
###############################################################################

source ../../../scripts/adi_env.tcl
source $ad_hdl_dir/projects/scripts/adi_project_xilinx.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

# Make the Digilent Genesys ZU-5EV board files visible to Vivado.
# Set the GENESYS_ZU_BOARD_FILES environment variable to override, or install
# the board files into Vivado and remove this block.
if {[info exists ::env(GENESYS_ZU_BOARD_FILES)]} {
  set_param board.repoPaths [list $::env(GENESYS_ZU_BOARD_FILES)]
} else {
  # WSL/Linux Vivado needs the /mnt/d view; fall back to the Windows path.
  set _gzu_bf "/mnt/d/digilent-vivado-boards/new/board_files"
  if {![file isdirectory $_gzu_bf]} { set _gzu_bf "D:/digilent-vivado-boards/new/board_files" }
  set_param board.repoPaths [list $_gzu_bf]
}

set GENESYS_ZU_BOARD [lindex [lsearch -all -inline [get_board_parts] digilentinc.com:gzu_5ev:*] end]
if {$GENESYS_ZU_BOARD eq ""} {
  return -code error "ERROR: Genesys ZU-5EV board files not found; check board.repoPaths above."
}

# Parameter description
#
# ADC_N_BITS - AD4080 sample width (20 for full-precision SAR output).

set ADC_N_BITS [get_env_param ADC_N_BITS 20]

# The carrier is not in adi_project's name->device table, so create the
# project directly with an explicit device and board part.
adi_project_create ad4080_fmc_evb_genesys_zu5ev 0 [list \
  ADC_N_BITS $ADC_N_BITS ] \
  "xczu5ev-sfvc784-1-e" \
  $GENESYS_ZU_BOARD

adi_project_files ad4080_fmc_evb_genesys_zu5ev [list \
    "$ad_hdl_dir/library/common/ad_iobuf.v" \
    "$ad_hdl_dir/projects/common/genesys-zu5ev/genesys_zu5ev_system_constr.xdc" \
    "system_constr.xdc" \
    "cso_open/cso_open.xdc" \
    "system_top.v" ]

# The license-free 10G custom IPs (open_mac_10g/xxv_shim/tx_csum_open) are staged
# in $ad_hdl_dir/library so adi_project_create's update_ip_catalog registers them
# BEFORE it builds the BD (create_bd_design + source system_bd.tcl happen inside
# adi_project_create, so injecting the repo here -- after -- is too late).

adi_project_run ad4080_fmc_evb_genesys_zu5ev
