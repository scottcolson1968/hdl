## Export the GUI-restructured block design to tcl (source-control the coherent
## FPD-control + HPC0 topology). No build/license needed.
open_project /mnt/d/hdl/projects/ad738x_fmc/genesys_zu5ev/ad738x_fmc_genesys_zu5ev.xpr
set bd [get_files -quiet */bd/system/system.bd]
puts "BD: $bd"
open_bd_design $bd
set out /mnt/d/hdl/projects/ad738x_fmc/genesys_zu5ev/system_bd_gui.tcl
write_bd_tcl -force $out
puts "WROTE-BD-TCL: $out exists=[file exists $out]"
exit 0
