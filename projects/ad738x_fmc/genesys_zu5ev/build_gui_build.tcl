## Headless recreate-and-build of the GUI (HLS 16ch) design from system_bd_gui.tcl.
## The saved .xpr/.bd are gone, so rebuild the bd from the write_bd_tcl export,
## then drive synth/impl/bitstream + XSA with the ADI top wrapper + 4sdi constr.
set proj ad738x_fmc_genesys_zu5ev
set part xczu5ev-sfvc784-1-e
set hdl  /mnt/d/hdl

# Digilent board files (same path the prior GUI build used)
set bf /mnt/d/digilent-vivado-boards/new/board_files
if {![file isdirectory $bf]} { set bf "D:/digilent-vivado-boards/new/board_files" }
set_param board.repoPaths [list $bf]

# Fresh project in-place (overwrites the 4ch make-flow project)
create_project -force $proj [pwd] -part $part
set bp [lindex [lsearch -all -inline [get_board_parts] digilentinc.com:gzu_5ev:*] end]
if {$bp eq ""} { return -code error "Genesys ZU board part not found" }
set_property BOARD_PART $bp [current_project]

# IP repo: ADI library tree (spi_engine, axi_dmac, streamToSteam HLS, etc.)
# plus our open TX checksum-offload IP (cso_open/iprepo).
set_property ip_repo_paths [list $hdl/library [pwd]/cso_open/iprepo] [current_fileset]
update_ip_catalog

# Build the block design from the GUI export (creates + validates + saves bd)
set design_name system
source system_bd_gui.tcl
set_property -dict [list CONFIG.PULSE_0_PERIOD {40}] [get_bd_cells spi_trigger_gen]
# ADC "en" enable GPIO -> axi_ad738x_dma/sync (see adc_en_gpio.tcl)
source adc_en_gpio.tcl
# RGB status LED (LD5) AXI GPIO -> external rgb_led_o (see rgb_led_gpio.tcl)
source rgb_led_gpio.tcl
# Async 4.096 MSPS trigger: clk_wiz(102.4)->fit_timer(/25) (see async_4096_trigger.tcl)
source async_4096_trigger.tcl
# TX TCP checksum offload: splice tx_csum_open into the XXV tx path (see tx_csum_splice.tcl)
source tx_csum_splice.tcl
save_bd_design
puts "GUI-BD-VALIDATED cells=[llength [get_bd_cells]] hls=[llength [get_bd_cells -quiet -filter {VLNV =~ *hls:streamToSteam*}]]"

# Wrapper + ADI top
make_wrapper -files [get_files system.bd] -top -import
add_files -norecurse system_top.v
set_property top system_top [current_fileset]

# Constraints (NUM_OF_SDI=4)
add_files -fileset constrs_1 -norecurse [list \
  $hdl/projects/common/genesys-zu5ev/genesys_zu5ev_system_constr.xdc \
  [pwd]/system_constr.xdc \
  [pwd]/system_constr_4sdi.xdc ]

generate_target all [get_files system.bd]
puts "GUI-GENERATE-DONE"

launch_runs synth_1 -jobs 8
wait_on_run synth_1
puts "SYNTH-STATUS: [get_property STATUS [get_runs synth_1]]"
launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1
puts "IMPL-STATUS: [get_property STATUS [get_runs impl_1]]"

set bit [get_property DIRECTORY [get_runs impl_1]]/system_top.bit
puts "BUILD-BIT: $bit exists=[file exists $bit]"

file mkdir ${proj}.sdk
write_hw_platform -fixed -include_bit -force ${proj}.sdk/system_top.xsa
puts "GUI-BUILD-DONE xsa=[file exists ${proj}.sdk/system_top.xsa]"
exit 0
