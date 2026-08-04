###############################################################################
## TX TCP checksum offload splice
##
## Inserts the open (unencrypted) autonomous checksum engine tx_csum_open into
## the XXV transmit AXIS path:
##     before:  eth_tx_fifo/M_AXIS -----------------------> xxv_eth/axis_tx_0
##     after:   eth_tx_fifo/M_AXIS -> tx_csum_open/s_axis
##              tx_csum_open/m_axis --------------------->  xxv_eth/axis_tx_0
##
## tx_csum_open parses Eth/IPv4/TCP and rewrites the L4 checksum field; the
## whole TX stream is on xxv_eth/tx_clk_out_0, so it is single-clock (no CDC).
## Autonomous => MCDMA stscntrl stays 0, RX path untouched. Pair with the
## driver's xlnx,txcsum=1 (advertises NETIF_F_HW_CSUM) + the kernel patch.
##
## Sourced from build_gui_build.tcl AFTER system_bd_gui.tcl (and the other
## overlays), so it layers on top of the GUI-exported design. Requires the
## cso_open/iprepo IP repo to be on ip_repo_paths (added in build_gui_build.tcl).
##
## Known limitation: 3-pass store-and-forward, throughput ceiling ~ tx_clk*64/3
## (~3.3 Gb/s @ 156.25 MHz) -- exceeds the current ~2 Gb/s link but below 10G
## line rate. If offload lifts throughput into this ceiling, optimise to 2-pass
## (accumulate during fill) or ping-pong buffering.
###############################################################################

set csum_cell [create_bd_cell -type ip -vlnv user.org:user:tx_csum_open:1.0 tx_csum_open]

# Straddle eth_tx_fifo: tap the stream on BOTH sides (input = accumulate csum,
# output = patch csum field). eth_tx_fifo (packet mode) does the buffering.
#   before:  eth_mcdma/M_AXIS_MM2S -> eth_tx_fifo/S_AXIS
#            eth_tx_fifo/M_AXIS     -> xxv_eth/axis_tx_0
#   after:   eth_mcdma/M_AXIS_MM2S -> s_in ; m_fifo -> eth_tx_fifo/S_AXIS
#            eth_tx_fifo/M_AXIS    -> s_fifo ; m_out -> xxv_eth/axis_tx_0
delete_bd_objs [get_bd_intf_nets eth_mcdma_M_AXIS_MM2S]
delete_bd_objs [get_bd_intf_nets eth_tx_fifo_M_AXIS]
connect_bd_intf_net [get_bd_intf_pins eth_mcdma/M_AXIS_MM2S] [get_bd_intf_pins tx_csum_open/s_in]
connect_bd_intf_net [get_bd_intf_pins tx_csum_open/m_fifo]   [get_bd_intf_pins eth_tx_fifo/S_AXIS]
connect_bd_intf_net [get_bd_intf_pins eth_tx_fifo/M_AXIS]    [get_bd_intf_pins tx_csum_open/s_fifo]
connect_bd_intf_net [get_bd_intf_pins tx_csum_open/m_out]    [get_bd_intf_pins xxv_eth/axis_tx_0]

# Same clock/reset domain as eth_tx_fifo (the MAC tx clock + tx reset).
connect_bd_net -net xxv_eth_tx_clk_out_0 [get_bd_pins tx_csum_open/aclk]
connect_bd_net -net tx_rst_n_Res         [get_bd_pins tx_csum_open/aresetn]

validate_bd_design
puts "TX-CSUM-SPLICE: tx_csum_open spliced eth_tx_fifo/M_AXIS -> tx_csum_open -> xxv_eth/axis_tx_0"
