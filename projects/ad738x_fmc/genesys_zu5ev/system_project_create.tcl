###############################################################################
## Copyright (C) 2019-2025 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
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
# ALERT_SPI_N - SDOB-SDOD/ALERT pin can operate as a serial data output pin or alert indication output
#  - Options : SDOB-SDOD(0)/ALERT(1)
# NUM_OF_SDI - Number of SDI lines used
#  - Options : 1,2,4

# The carrier is not in adi_project's name->device table, so create the
# project directly with an explicit device and board part.
adi_project_create ad738x_fmc_genesys_zu5ev 0 [list \
  ALERT_SPI_N [get_env_param ALERT_SPI_N  0]\
  NUM_OF_SDI [get_env_param NUM_OF_SDI    4] ] \
  "xczu5ev-sfvc784-1-e" \
  $GENESYS_ZU_BOARD

adi_project_files ad738x_fmc_genesys_zu5ev [list \
    "$ad_hdl_dir/projects/common/genesys-zu5ev/genesys_zu5ev_system_constr.xdc" \
    "system_constr.xdc" \
    "system_top.v" ]

switch [get_env_param NUM_OF_SDI 4] {
  1 {
    adi_project_files ad738x_fmc_genesys_zu5ev [list \
      "system_constr_1sdi.xdc" ]
  }
  2 {
    adi_project_files ad738x_fmc_genesys_zu5ev [list \
     "system_constr_2sdi.xdc" ]
 }
  4 {
   adi_project_files ad738x_fmc_genesys_zu5ev [list \
     "system_constr_4sdi.xdc" ]
  }
  default {
    adi_project_files ad738x_fmc_genesys_zu5ev [list \
      "system_constr_1sdi.xdc" ]
  }
}

