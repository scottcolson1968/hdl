## Build the GUI-restructured design FROM THE SAVED PROJECT (open_project, not the
## ADI tcl flow -- that would regenerate the bd from tcl and wipe the GUI edits).
set xpr /mnt/d/hdl/projects/ad738x_fmc/genesys_zu5ev/ad738x_fmc_genesys_zu5ev.xpr
open_project $xpr
puts "OPENED: top=[get_property top [current_fileset]]"
## Regenerate output products from the SAVED bd (idempotent; uses GUI edits, not tcl)
set bd [get_files -quiet */bd/system/system.bd]
puts "BD: $bd"
if {$bd ne ""} { catch {generate_target all [get_files $bd]} }
reset_run synth_1
launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1
puts "BUILD-SYNTH-STATUS: [get_property STATUS [get_runs synth_1]]"
puts "BUILD-IMPL-STATUS: [get_property STATUS [get_runs impl_1]]"
puts "BUILD-IMPL-PROGRESS: [get_property PROGRESS [get_runs impl_1]]"
set bit [get_property DIRECTORY [get_runs impl_1]]/system_top.bit
puts "BUILD-BIT: $bit exists=[file exists $bit]"
puts "BUILD-DONE"
exit 0
