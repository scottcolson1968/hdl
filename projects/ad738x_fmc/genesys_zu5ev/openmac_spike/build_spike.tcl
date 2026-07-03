# License-free 10G spike: xxv_ethernet PCS/PMA-only (free) + open eth_mac_10g.
# Success criterion: write_bitstream completes WITHOUT the XXV MAC license
# (run with WSL eth0 NOT set to the license MAC to make the proof airtight).
set part xczu5ev-sfvc784-1-e
set spike /mnt/d/hdl/projects/ad738x_fmc/genesys_zu5ev/openmac_spike
set ve    /mnt/d/verilog-ethernet/rtl

create_project -force openmac_spike /home/scott/openmac_spike -part $part

# --- free PCS/PMA-only core, same GT setup as production ---
create_ip -vlnv [lindex [get_ipdefs -all *xxv_ethernet*] 0] -module_name xxv_pcs
set_property -dict [list \
    CONFIG.CORE {Ethernet PCS/PMA 64-bit} \
    CONFIG.BASE_R_KR {BASE-R} \
    CONFIG.NUM_OF_CORES 1 \
    CONFIG.GT_REF_CLK_FREQ 156.25 \
    CONFIG.GT_GROUP_SELECT {Quad_X0Y1} \
    CONFIG.LANE1_GT_LOC {X0Y7} \
    CONFIG.GT_LOCATION 1 \
] [get_ips xxv_pcs]
generate_target all [get_ips xxv_pcs]

# --- open-source MAC + deps (MIT) ---
add_files -norecurse [list \
    $ve/eth_mac_10g.v \
    $ve/axis_xgmii_rx_64.v \
    $ve/axis_xgmii_tx_64.v \
    $ve/mac_ctrl_rx.v \
    $ve/mac_ctrl_tx.v \
    $ve/mac_pause_ctrl_rx.v \
    $ve/mac_pause_ctrl_tx.v \
    $ve/lfsr.v \
    $spike/openmac_spike_top.v ]
set_property top openmac_spike_top [current_fileset]

# --- constraints: real GT refclk pins; waive the spike-only loose ends ---
set xdc [open /home/scott/openmac_spike/spike.xdc w]
puts $xdc {set_property PACKAGE_PIN Y6 [get_ports gt_refclk_p]}
puts $xdc {set_property PACKAGE_PIN Y5 [get_ports gt_refclk_n]}
puts $xdc {create_clock -period 6.400 -name gt_refclk [get_ports gt_refclk_p]}
close $xdc
add_files -fileset constrs_1 /home/scott/openmac_spike/spike.xdc

launch_runs synth_1 -jobs 8
wait_on_run synth_1
puts "SPIKE-SYNTH: [get_property STATUS [get_runs synth_1]]"
if {[get_property PROGRESS [get_runs synth_1]] ne "100%"} { puts "SPIKE-FAIL synth"; exit 1 }

# spike-only DRC relaxations (dclk/led have no pin LOCs)
set_property STEPS.WRITE_BITSTREAM.TCL.PRE /home/scott/openmac_spike/pre_bit.tcl [get_runs impl_1]
set pre [open /home/scott/openmac_spike/pre_bit.tcl w]
puts $pre {set_property SEVERITY {Warning} [get_drc_checks NSTD-1]}
puts $pre {set_property SEVERITY {Warning} [get_drc_checks UCIO-1]}
close $pre

launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1
puts "SPIKE-IMPL: [get_property STATUS [get_runs impl_1]]"
set bit /home/scott/openmac_spike/openmac_spike.runs/impl_1/openmac_spike_top.bit
puts "SPIKE-BIT: exists=[file exists $bit]"
exit 0
