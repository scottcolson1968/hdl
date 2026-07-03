# Package the open-MAC migration IPs into cso_open/iprepo:
#   user.org:user:open_mac_10g:1.0  (eth_mac_10g wrapper + verilog-ethernet deps)
#   user.org:user:xxv_shim:1.0      (AXI-lite XXV MAC register emulation)
# Run under Vivado 2025.1 batch (WSL).
set part xczu5ev-sfvc784-1-e
set hdl  /mnt/d/hdl/projects/ad738x_fmc/genesys_zu5ev/cso_open/hdl
set ve   /mnt/d/verilog-ethernet
set repo /mnt/d/hdl/projects/ad738x_fmc/genesys_zu5ev/cso_open/iprepo

# ---------------- open_mac_10g ----------------
create_project -force pkg_mac /home/scott/pkg_mac -part $part
add_files -norecurse [list \
    $hdl/open_mac_10g.v \
    $ve/rtl/eth_mac_10g.v \
    $ve/rtl/axis_xgmii_rx_64.v \
    $ve/rtl/axis_xgmii_tx_64.v \
    $ve/rtl/mac_ctrl_rx.v \
    $ve/rtl/mac_ctrl_tx.v \
    $ve/rtl/mac_pause_ctrl_rx.v \
    $ve/rtl/mac_pause_ctrl_tx.v \
    $ve/rtl/lfsr.v \
    $ve/lib/axis/rtl/axis_fifo.v ]
set_property top open_mac_10g [current_fileset]
update_compile_order -fileset sources_1
file mkdir $repo/open_mac_10g
ipx::package_project -root_dir $repo/open_mac_10g -vendor user.org -library user \
    -taxonomy /UserIP -force -import_files -set_current true
set core [ipx::current_core]
set_property version 1.0 $core
set_property display_name {Open 10G Ethernet MAC (verilog-ethernet)} $core
set_property description {License-free 10G MAC: eth_mac_10g + bad-frame-drop RX FIFO, XGMII to free BASE-R PCS/PMA} $core
ipx::associate_bus_interfaces -busif s_axis_tx -clock tx_clk $core
ipx::associate_bus_interfaces -busif m_axis_rx -clock rx_clk $core
# resets tx_rst/rx_rst: no 'n' suffix -> packager infers ACTIVE_HIGH (matches
# the PCS user_*_reset polarity); verify in the interface dump below.
ipx::create_xgui_files $core
ipx::update_checksums $core
ipx::save_core $core
puts "PKG-MAC-DONE"
foreach bi [ipx::get_bus_interfaces -of_objects $core] {
    puts "  MAC-IF: [get_property name $bi] -> [get_property bus_type_vlnv $bi]"
}
close_project

# ---------------- xxv_shim ----------------
create_project -force pkg_shim /home/scott/pkg_shim -part $part
add_files -norecurse $hdl/xxv_shim.v
set_property top xxv_shim [current_fileset]
file mkdir $repo/xxv_shim
ipx::package_project -root_dir $repo/xxv_shim -vendor user.org -library user \
    -taxonomy /UserIP -force -import_files -set_current true
set core [ipx::current_core]
set_property version 1.0 $core
set_property display_name {XXV MAC register shim} $core
set_property description {AXI-lite emulation of the XXV MAC regs the axienet driver touches; zero driver/DT change} $core
ipx::associate_bus_interfaces -busif s_axi -clock s_axi_aclk $core
ipx::create_xgui_files $core
ipx::update_checksums $core
ipx::save_core $core
puts "PKG-SHIM-DONE"
foreach bi [ipx::get_bus_interfaces -of_objects $core] {
    puts "  SHIM-IF: [get_property name $bi] -> [get_property bus_type_vlnv $bi]"
}
exit 0
