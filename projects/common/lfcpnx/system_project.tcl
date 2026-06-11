###############################################################################
## Copyright (C) 2023-2025 Analog Devices, Inc. All rights reserved.
###
### In this HDL repository, there are many different and unique modules, consisting
### of various HDL (Verilog or VHDL) components. The individual modules are
### developed independently, and may be accompanied by separate and unique license
### terms.
###
### The user should read each of these license terms, and understand the
### freedoms and responsibilities that he or she has by using this source/core.
###
### This core is distributed in the hope that it will be useful, but WITHOUT ANY
### WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
### A PARTICULAR PURPOSE.
###
### Redistribution and use of source or resulting binaries, with or without modification
### of this file, are permitted under one of the following two license terms:
###
###   1. The GNU General Public License version 2 as published by the
###      Free Software Foundation, which can be found in the top level directory
###      of this repository (LICENSE_GPL2), and also online at:
###      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
###
### OR
###
###   2. An ADI specific BSD license, which can be found in the top level directory
###      of this repository (LICENSE_ADIBSD), and also on-line at:
###      https://github.com/analogdevicesinc/hdl/blob/main/LICENSE_ADIBSD
###      This will allow to generate bit files and not release the source code,
###      as long as it attaches to an ADI device.
###
### ***************************************************************************
### ***************************************************************************
###############################################################################

## default options for adi_project ############################################
## if the -dev_select "manual" then the -device, -speed and -board options can
## be set manually.
# adi_project $project_name \
#   -dev_select "auto" \
#   -ppath "./$project_name" \
#   -device "" \
#   -speed "" \
#   -board "" \
#   -synthesis "synplify" \
#   -impl "impl_1" \
#   -cmd_list ""

## default options for adi_project_files_auto #################################
# adi_project_files_auto $project_name \
#   -exts {*.ipx} \
#   -spath ./$project_name/project_name/lib \
#   -ppath "./$project_name" \
#   -sdepth "6" \
#   -opt_args ""
## use case 0 #################################################################
# adi_project_files_auto $project_name \
#   -exts [list *.ipx $project_name.v] \
#   -spath ./ \
#   -ppath "./$project_name" \
#   -sdepth "9" \
#   -opt_args "<opt args for prj_add_source Radiant tcl command>"

## options for adi_project_files ##############################################
# adi_project_files $project_name \
#   -ppath "./$project_name" \
#   -flist [list system_top.v \
#     ./lfcpnx_system_constr.pdc \
#     "$ad_hdl_dir/library/common/ad_iobuf.v"]
#   -opt_args "<opt args for prj_add_source Radiant tcl command>"

## default options for adi_project_run_cmd ####################################
# adi_project_run_cmd $project_name \
#   -ppath "./$project_name" \
#   -cmd_list ""
# example commands ############################################################
# adi_project_run_cmd $project_name -ppath ./$project_name \
#   -cmd_list { \
#     {prj_clean_impl -impl $impl} \
#     {prj_set_impl_opt -impl $impl "include path" "."} \
#     {prj_set_impl_opt -impl $impl "top" $top} \
#     {prj_set_strategy_value -strategy Strategy1 bit_ip_eval=True} \
#     {prj_set_strategy_value -strategy Strategy1 syn_force_gsr=False} \
#     {prj_set_strategy_value -strategy Strategy1 map_infer_gsr=False} \
#     {prj_set_strategy_value -strategy Strategy1 par_place_iterator=10} \
#     {prj_set_strategy_value -strategy Strategy1 par_stop_zero=True} \
#   }

## default options for adi_project_run ########################################
# adi_project_run $project_name \
#   -ppath ./$project_name \
#   -mode "export" \
#   -impl "impl_1" \
#   -top "system_top" \
#   -cmd_list ""

source ../../../scripts/adi_env.tcl
source $ad_hdl_dir/projects/scripts/adi_project_lattice.tcl

# Creates the Radiant project with default configurations.
# The device parameters are extracted by matching part of the project name.
adi_project template_lfcpnx

# Adds the generated file dependencies by Propel Builder to the Radiant project.
adi_project_files_default template_lfcpnx

# Adds the other not generated file dependencies to Radiant project.
adi_project_files template_lfcpnx -flist [list \
  system_top.v \
  lfcpnx_system_constr.pdc]

adi_project_run template_lfcpnx \
  -cmd_list { \
    {prj_clean_impl -impl $impl} \
    {prj_set_strategy_value -strategy Strategy1 bit_ip_eval=True} \
    {prj_set_strategy_value -strategy Strategy1 par_place_iterator_start_pt=1} \
    {prj_set_strategy_value -strategy Strategy1 par_place_iterator=0} \
    {prj_set_strategy_value -strategy Strategy1 par_save_best_result=1} \
    {prj_set_strategy_value -strategy Strategy1 syn_frequency=} \
  }
