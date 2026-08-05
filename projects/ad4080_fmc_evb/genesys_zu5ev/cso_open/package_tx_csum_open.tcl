# Package tx_csum_open.v as a Vivado IP (user.org:user:tx_csum_open:1.0)
# into cso_open/iprepo/tx_csum_open. Run under Vivado 2025.1 batch.
set part xczu5ev-sfvc784-1-e
set src  /mnt/d/hdl/projects/ad738x_fmc/genesys_zu5ev/cso_open/hdl/tx_csum_open.v
set root /mnt/d/hdl/projects/ad738x_fmc/genesys_zu5ev/cso_open/iprepo/tx_csum_open
file mkdir $root

create_project -force pkg /home/scott/csum_pkg -part $part
add_files -norecurse $src
set_property top tx_csum_open [current_fileset]
update_compile_order -fileset sources_1

ipx::package_project -root_dir $root -vendor user.org -library user \
    -taxonomy /UserIP -force -import_files -set_current true
set core [ipx::current_core]
set_property version      1.0 $core
set_property display_name {TX TCP Checksum Offload (open)} $core
set_property description   {Unencrypted TX partial TCP/UDP checksum insertion for XXV+MCDMA} $core

# clock associations (all 4 AXIS ifaces straddling the tx FIFO) + active-low reset
ipx::associate_bus_interfaces -busif s_in   -clock aclk $core
ipx::associate_bus_interfaces -busif m_fifo -clock aclk $core
ipx::associate_bus_interfaces -busif s_fifo -clock aclk $core
ipx::associate_bus_interfaces -busif m_out  -clock aclk $core

puts "=== inferred bus interfaces ==="
foreach bi [ipx::get_bus_interfaces -of_objects $core] {
    puts "  [get_property name $bi]  ->  [get_property bus_type_vlnv $bi]"
}

ipx::create_xgui_files $core
ipx::update_checksums $core
ipx::save_core $core
puts "PACKAGE_DONE root=$root"
