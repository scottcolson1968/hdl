###############################################################################
## Open-MAC migration splice (license-free 10G)
##
## Replaces the licensed XXV MAC with:
##   * xxv_eth reconfigured to CORE = "Ethernet PCS/PMA 64-bit" (FREE BASE-R
##     PHY, no license, no eval timebomb)
##   * open_mac_10g (verilog-ethernet eth_mac_10g, MIT) on its XGMII/mii pins
##   * xxv_shim: AXI-lite emulation of the XXV MAC registers at 0x80060000 so
##     the stock xilinx_axienet driver + DT run UNCHANGED
##
## Sourced from build_gui_build.tcl AFTER tx_csum_splice.tcl. When the CORE is
## reconfigured, the MAC-mode pins (axis_tx_0/axis_rx_0/s_axi_0/tx_clk_out_0/
## preamble/ctl_tx_send_*) vanish -- their connections drop automatically and
## are re-established below onto the new mii/tx_mii_clk_0 pins. rx_clk_out_0,
## user/tx/rx resets, gtwiz resets, dclk, outclksel and qpllreset pins persist.
##
##   TX: mcdma -> tx_csum_open(s_in..m_fifo) -> eth_tx_fifo ->
##       tx_csum_open(s_fifo..m_out) -> open_mac_10g -> xgmii -> PCS -> GT
##   RX: GT -> PCS -> xgmii -> open_mac_10g (FCS check/strip + drop-bad) ->
##       eth_rx_fifo -> mcdma
###############################################################################

# --- 1. reconfigure xxv_eth to the free PCS/PMA-only core -------------------
set_property -dict [list \
    CONFIG.CORE {Ethernet PCS/PMA 64-bit} \
    CONFIG.BASE_R_KR {BASE-R} \
    CONFIG.NUM_OF_CORES {1} \
    CONFIG.GT_REF_CLK_FREQ {156.25} \
    CONFIG.GT_GROUP_SELECT {Quad_X0Y1} \
    CONFIG.LANE1_GT_LOC {X0Y7} \
    CONFIG.GT_LOCATION {1} \
] [get_bd_cells xxv_eth]
catch { set_property CONFIG.INCLUDE_STATISTICS_COUNTERS 0 [get_bd_cells xxv_eth] }

# --- 2. new cells ------------------------------------------------------------
set mac  [create_bd_cell -type ip -vlnv user.org:user:open_mac_10g:1.0 open_mac]
set shim [create_bd_cell -type ip -vlnv user.org:user:xxv_shim:1.0 xxv_shim]

# --- 3. TX/RX datapath -------------------------------------------------------
# tx_csum_open/m_out lost its peer (axis_tx_0 gone) -> feed the open MAC
connect_bd_intf_net [get_bd_intf_pins tx_csum_open/m_out] [get_bd_intf_pins open_mac/s_axis_tx]
# eth_rx_fifo/S_AXIS lost its driver (axis_rx_0 gone) -> feed from the open MAC
connect_bd_intf_net [get_bd_intf_pins open_mac/m_axis_rx] [get_bd_intf_pins eth_rx_fifo/S_AXIS]
# XGMII <-> PCS mii pins
connect_bd_net [get_bd_pins open_mac/xgmii_txd] [get_bd_pins xxv_eth/tx_mii_d_0]
connect_bd_net [get_bd_pins open_mac/xgmii_txc] [get_bd_pins xxv_eth/tx_mii_c_0]
connect_bd_net [get_bd_pins xxv_eth/rx_mii_d_0] [get_bd_pins open_mac/xgmii_rxd]
connect_bd_net [get_bd_pins xxv_eth/rx_mii_c_0] [get_bd_pins open_mac/xgmii_rxc]

# --- 4. clocks / resets ------------------------------------------------------
# tx domain: tx_mii_clk_0 replaces tx_clk_out_0; rejoin the surviving net that
# still feeds eth_tx_fifo / mcdma MM2S / hp2 aclk1 / tx_csum_open.
connect_bd_net -net [get_bd_nets xxv_eth_tx_clk_out_0] [get_bd_pins xxv_eth/tx_mii_clk_0]
connect_bd_net -net [get_bd_nets xxv_eth_tx_clk_out_0] [get_bd_pins open_mac/tx_clk]
# rx domain: rx_clk_out_0 net survives; add the MAC
connect_bd_net -net [get_bd_nets xxv_eth_rx_clk_out_0] [get_bd_pins open_mac/rx_clk]
# MAC resets = PCS user resets (active-high, pins persist)
connect_bd_net -net [get_bd_nets xxv_eth_user_tx_reset_0] [get_bd_pins open_mac/tx_rst]
connect_bd_net -net [get_bd_nets xxv_eth_user_rx_reset_0] [get_bd_pins open_mac/rx_rst]

# --- 5. register shim on the freed AXI slot ---------------------------------
# after s_axi_0 vanishes the old M06 net may linger one-ended OR be pruned --
# delete whatever lingers, then connect fresh. Fail loudly if pins missing.
# ADI ad_cpu_interconnect flow: there is NO GUI axi_smc/M06_AXI here. xxv_eth's
# s_axi_0 is intentionally NOT assigned in system_bd.tcl (it vanishes on the
# PCS/PMA reconfig above), so map the shim's AXI-lite slave fresh at 0x80060000
# via the ADI helper -- it adds the interconnect master + wires aclk + assigns.
connect_bd_net -net [get_bd_nets sys_cpu_clk]    [get_bd_pins xxv_shim/s_axi_aclk]
connect_bd_net -net [get_bd_nets sys_cpu_resetn] [get_bd_pins xxv_shim/s_axi_aresetn]
ad_cpu_interconnect 0x80060000 xxv_shim s_axi

# --- 6. status / control cross-wiring ---------------------------------------
connect_bd_net [get_bd_pins xxv_eth/stat_rx_block_lock_0] [get_bd_pins xxv_shim/block_lock]
connect_bd_net [get_bd_pins xxv_shim/cfg_tx_enable] [get_bd_pins open_mac/cfg_tx_enable]
connect_bd_net [get_bd_pins xxv_shim/cfg_rx_enable] [get_bd_pins open_mac/cfg_rx_enable]

validate_bd_design
puts "OPEN-MAC-SPLICE: PCS-only xxv + open_mac_10g + xxv_shim@0x80060000 wired"
