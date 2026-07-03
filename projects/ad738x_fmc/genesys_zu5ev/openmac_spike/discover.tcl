# Discover xxv_ethernet PCS/PMA-only configuration + ports (2025.1, xczu5ev)
create_project -force disc /home/scott/openmac_disc -part xczu5ev-sfvc784-1-e
create_ip -vlnv [lindex [get_ipdefs -all *xxv_ethernet*] 0] -module_name xxv_pcs
set ip [get_ips xxv_pcs]
puts "CORE-OPTIONS: [list_property_value CONFIG.CORE $ip]"
set_property -dict [list \
  CONFIG.CORE {Ethernet PCS/PMA 64-bit} \
  CONFIG.BASE_R_KR {BASE-R} \
  CONFIG.NUM_OF_CORES 1 \
  CONFIG.GT_REF_CLK_FREQ 156.25 \
  CONFIG.GT_GROUP_SELECT {Quad_X0Y1} \
  CONFIG.LANE1_GT_LOC {X0Y7} \
  CONFIG.GT_LOCATION 1 \
] $ip
puts "CORE-SET: [get_property CONFIG.CORE $ip]"
puts "LICENSE-CHECK:"
report_property $ip -regexp {.*LICENSE.*} 
generate_target {instantiation_template} $ip
set tpl [get_property IP_FILE $ip]
puts "=== ports (from generated component) ==="
foreach p [get_property MODELPARAM_VALUE.* $ip] {}
# dump the instantiation template
set veo [glob -nocomplain /home/scott/openmac_disc/disc.gen/sources_1/ip/xxv_pcs/*.veo]
if {$veo ne ""} { set f [open [lindex $veo 0] r]; puts [read $f]; close $f }
exit 0
