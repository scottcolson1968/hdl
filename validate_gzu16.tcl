## Structural validation of the 4ch->16ch streamToSteam change.
## Creates the project + bd (running the edited system_bd.tcl / common) and
## validates — no synth/impl, so no XXV license needed.
source system_project_create.tcl

puts "VALIDATE: streamToSteam cell = [get_bd_cells -quiet streamToSteam_0]"
puts "VALIDATE: dma s_axis width   = [get_property CONFIG.DMA_DATA_WIDTH_SRC [get_bd_cells -quiet axi_ad738x_dma]]"
puts "VALIDATE: dma dest width     = [get_property CONFIG.DMA_DATA_WIDTH_DEST [get_bd_cells -quiet axi_ad738x_dma]]"

if {[catch {validate_bd_design} verr]} {
  puts "VALIDATE-ERROR: $verr"
} else {
  puts "VALIDATE-OK"
}
catch {save_bd_design}
puts "VALIDATE-DONE"
exit 0
