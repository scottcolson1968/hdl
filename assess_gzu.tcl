## Read-only assessment of the copied 16ch project in Vivado 2025.1.
## Opens the 2024.1 project, reports migration + IP-upgrade status, does NOT build.
set xpr /mnt/d/hdl/projects/ad738x_fmc/gzu_5ev/ALERTSPIN0_NUMOFSDI4/ad738x_fmc_gzu_5ev.xpr
puts "ASSESS: opening $xpr"
if {[catch {open_project $xpr} err]} {
  puts "ASSESS-OPEN-ERROR: $err"
  exit 1
}
puts "ASSESS-PART: [get_property part [current_project]]"
puts "ASSESS-TOP: [get_property top [current_fileset]]"
puts "ASSESS: ===== IP status ====="
catch {report_ip_status -quiet}
puts "ASSESS: ===== locked/upgrade IPs ====="
foreach ip [get_ips] {
  set locked [get_property IS_LOCKED $ip]
  set upg [get_property UPGRADE_VERSIONS $ip]
  puts "IP: $ip locked=$locked ver=[get_property SW_VERSION $ip]"
}
puts "ASSESS-DONE"
close_project
exit 0
