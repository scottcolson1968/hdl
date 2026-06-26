###############################################################################
## Copyright (C) 2019-2025 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################

source $ad_hdl_dir/projects/common/genesys-zu5ev/genesys_zu5ev_system_bd.tcl
source $ad_hdl_dir/projects/scripts/adi_pd.tcl

# block design
source ../common/ad738x_bd.tcl

# system ID
ad_ip_parameter axi_sysid_0 CONFIG.ROM_ADDR_BITS 9
ad_ip_parameter rom_sys_0 CONFIG.PATH_TO_FILE "$mem_init_sys_file_path/mem_init_sys.txt"
ad_ip_parameter rom_sys_0 CONFIG.ROM_ADDR_BITS 9

set sys_cstring "ALERT_SPI_N=$ad_project_params(ALERT_SPI_N)\
NUM_OF_SDI=$ad_project_params(NUM_OF_SDI)"

sysid_gen_sys_init_file $sys_cstring

###############################################################################
# 10G Ethernet over SFP+ (GTH bank 224 ch3 = Quad_X0Y1 lane X0Y7).
# xxv_ethernet MAC+PCS 64-bit BASE-R + AXI DMA, everything in the tx_mii_clk
# (156.25 MHz) domain so RX can sustain line rate; HP1 carries DMA traffic.
# Driven by the xlnx axienet driver ("xlnx,xxv-ethernet-1.0" +
# axistream-connected AXI DMA).
###############################################################################

ad_ip_instance xxv_ethernet xxv_eth
ad_ip_parameter xxv_eth CONFIG.CORE {Ethernet MAC+PCS/PMA 64-bit}
# board-aware flows default to GT-outside-the-core, removing the gt_* pins
ad_ip_parameter xxv_eth CONFIG.GT_LOCATION 1
ad_ip_parameter xxv_eth CONFIG.BASE_R_KR {BASE-R}
ad_ip_parameter xxv_eth CONFIG.NUM_OF_CORES 1
ad_ip_parameter xxv_eth CONFIG.GT_REF_CLK_FREQ 156.25
ad_ip_parameter xxv_eth CONFIG.GT_GROUP_SELECT {Quad_X0Y1}
ad_ip_parameter xxv_eth CONFIG.LANE1_GT_LOC {X0Y7}
ad_ip_parameter xxv_eth CONFIG.INCLUDE_AXI4_INTERFACE 1
ad_ip_parameter xxv_eth CONFIG.INCLUDE_STATISTICS_COUNTERS 1

ad_ip_instance axi_dma eth_dma
ad_ip_parameter eth_dma CONFIG.c_include_sg 1
# CRITICAL: disable the SG status/control stream. When enabled (the IP default
# in this flow), the S2MM engine waits on the S_AXIS_S2MM_STS slave stream to
# finalize each RX descriptor. The XXV MAC doesn't provide that stream, so it
# dangles and RX writes land in DDR but never complete (no writeback, no IOC).
# The 10G/25G axienet driver derives RX length from the native BD status
# (status & ACTUAL_LEN_MASK), so the stream must be OFF.
ad_ip_parameter eth_dma CONFIG.c_sg_include_stscntrl_strm 0
# NOTE: c_prmry_is_aclk_async is propagation-owned and silently reverts to 0,
# so the lite clock MUST genuinely match the engine clocks (all tx_clk_out_0).
# The CPU-side smartconnect handles the sys_cpu_clk <-> tx_clk crossing.
ad_ip_parameter eth_dma CONFIG.c_sg_length_width 16
ad_ip_parameter eth_dma CONFIG.c_addr_width 40
ad_ip_parameter eth_dma CONFIG.c_m_axi_mm2s_data_width 64
ad_ip_parameter eth_dma CONFIG.c_m_axis_mm2s_tdata_width 64
ad_ip_parameter eth_dma CONFIG.c_m_axi_s2mm_data_width 64
ad_ip_parameter eth_dma CONFIG.c_s_axis_s2mm_tdata_width 64
ad_ip_parameter eth_dma CONFIG.c_mm2s_burst_size 64
# ZCU102 pl_eth_10g reference uses an 8-beat S2MM burst
ad_ip_parameter eth_dma CONFIG.c_s2mm_burst_size 8
ad_ip_parameter eth_dma CONFIG.c_include_mm2s_dre 1
ad_ip_parameter eth_dma CONFIG.c_include_s2mm_dre 1

# store-and-forward FIFOs: TX must not underrun mid-frame, RX cannot be
# backpressured by the MAC
ad_ip_instance axis_data_fifo eth_tx_fifo
ad_ip_parameter eth_tx_fifo CONFIG.FIFO_DEPTH 4096
ad_ip_parameter eth_tx_fifo CONFIG.FIFO_MODE 2
ad_ip_instance axis_data_fifo eth_rx_fifo
ad_ip_parameter eth_rx_fifo CONFIG.FIFO_DEPTH 32768
ad_ip_parameter eth_rx_fifo CONFIG.SYNCHRONIZATION_STAGES 3
ad_ip_parameter eth_rx_fifo CONFIG.FIFO_MODE 2
# RX AXIS lives in the rx_clk_out domain (recovered clock); async FIFO
# bridges it into the tx/DMA domain, per the Xilinx PL-Ethernet reference.
ad_ip_parameter eth_rx_fifo CONFIG.IS_ACLK_ASYNC 1

# 156.25 MHz ethernet clock domain reset
ad_ip_instance proc_sys_reset eth_clk_rstgen
ad_connect xxv_eth/tx_clk_out_0 eth_clk_rstgen/slowest_sync_clk
ad_connect sys_rstgen/peripheral_aresetn eth_clk_rstgen/ext_reset_in

# clocks: free-running dclk + AXI-lite on the cpu clock, datapath on tx_mii_clk
ad_connect sys_cpu_clk xxv_eth/dclk
ad_connect sys_cpu_clk xxv_eth/s_axi_aclk_0
ad_connect sys_cpu_resetn xxv_eth/s_axi_aresetn_0
ad_connect xxv_eth/rx_clk_out_0 xxv_eth/rx_core_clk_0

# rx-domain reset for the async fifo ingress
ad_ip_instance proc_sys_reset eth_rx_rstgen
ad_connect xxv_eth/rx_clk_out_0 eth_rx_rstgen/slowest_sync_clk
ad_connect sys_rstgen/peripheral_aresetn eth_rx_rstgen/ext_reset_in
ad_connect sys_rstgen/peripheral_reset xxv_eth/sys_reset

ad_connect xxv_eth/tx_clk_out_0 eth_dma/m_axi_sg_aclk
ad_connect xxv_eth/tx_clk_out_0 eth_dma/m_axi_mm2s_aclk
ad_connect xxv_eth/tx_clk_out_0 eth_dma/m_axi_s2mm_aclk
ad_connect xxv_eth/tx_clk_out_0 eth_dma/s_axi_lite_aclk
ad_connect eth_clk_rstgen/peripheral_aresetn eth_dma/axi_resetn

ad_connect xxv_eth/tx_clk_out_0 eth_tx_fifo/s_axis_aclk
ad_connect eth_clk_rstgen/peripheral_aresetn eth_tx_fifo/s_axis_aresetn
ad_connect xxv_eth/rx_clk_out_0 eth_rx_fifo/s_axis_aclk
ad_connect eth_rx_rstgen/peripheral_aresetn eth_rx_fifo/s_axis_aresetn
ad_connect xxv_eth/tx_clk_out_0 eth_rx_fifo/m_axis_aclk

# datapath: DMA MM2S -> tx fifo -> MAC; MAC RX -> rx fifo -> DMA S2MM
ad_connect eth_dma/M_AXIS_MM2S eth_tx_fifo/S_AXIS
ad_connect eth_tx_fifo/M_AXIS xxv_eth/axis_tx_0
ad_connect xxv_eth/axis_rx_0 eth_rx_fifo/S_AXIS
ad_connect eth_rx_fifo/M_AXIS eth_dma/S_AXIS_S2MM

# GT output clock selects: MUST be 3'b101 per gtwizard (exdes: "this value
# should not be changed"). Left unconnected they tie to 0 and rx_clk_out is
# a dead clock -- the RX AXIS domain never toggles while MAC stats count.
ad_ip_instance xlconstant outclksel_const
ad_ip_parameter outclksel_const CONFIG.CONST_WIDTH 3
ad_ip_parameter outclksel_const CONFIG.CONST_VAL 5
ad_connect outclksel_const/dout xxv_eth/txoutclksel_in_0
ad_connect outclksel_const/dout xxv_eth/rxoutclksel_in_0

# MAC control tie-offs
ad_connect xxv_eth/ctl_tx_send_idle_0 GND
ad_connect xxv_eth/ctl_tx_send_lfi_0 GND
ad_connect xxv_eth/ctl_tx_send_rfi_0 GND
ad_connect xxv_eth/tx_reset_0 GND
ad_connect xxv_eth/rx_reset_0 GND
ad_connect xxv_eth/gtwiz_reset_tx_datapath_0 GND
ad_connect xxv_eth/gtwiz_reset_rx_datapath_0 GND
ad_connect xxv_eth/qpllreset_in_0 GND
ad_connect xxv_eth/pm_tick_0 GND

# diagnostics: dump the IP's actual pins into the build log
puts "PINDUMP-GT_LOCATION: [get_property CONFIG.GT_LOCATION [get_bd_cells xxv_eth]]"
foreach pdump [get_bd_pins -of [get_bd_cells xxv_eth]] { puts "PINDUMP: $pdump" }
foreach pdump [get_bd_intf_pins -of [get_bd_cells xxv_eth]] { puts "INTFDUMP: $pdump [get_property VLNV $pdump]" }

# external GT + refclk ports
create_bd_port -dir I gt_refclk_p
create_bd_port -dir I gt_refclk_n
create_bd_port -dir I sfp_rxp
create_bd_port -dir I sfp_rxn
create_bd_port -dir O sfp_txp
create_bd_port -dir O sfp_txn
connect_bd_net [get_bd_ports gt_refclk_p] [get_bd_pins xxv_eth/gt_refclk_p]
connect_bd_net [get_bd_ports gt_refclk_n] [get_bd_pins xxv_eth/gt_refclk_n]
connect_bd_net [get_bd_ports sfp_rxp] [get_bd_pins xxv_eth/gt_rxp_in]
connect_bd_net [get_bd_ports sfp_rxn] [get_bd_pins xxv_eth/gt_rxn_in]
connect_bd_net [get_bd_pins xxv_eth/gt_txp_out] [get_bd_ports sfp_txp]
connect_bd_net [get_bd_pins xxv_eth/gt_txn_out] [get_bd_ports sfp_txn]

# register maps + DMA memory path + interrupts
ad_cpu_interconnect 0x84C00000 xxv_eth s_axi_0
ad_cpu_interconnect 0x84C10000 eth_dma S_AXI_LITE
# eth_dma's lite endpoint runs on tx_clk: hand that clock to the cpu
# smartconnect so it inserts the sys_cpu_clk <-> tx_clk converters itself
ad_ip_parameter axi_hpm0_lpd_interconnect CONFIG.NUM_CLKS 2
ad_connect xxv_eth/tx_clk_out_0 axi_hpm0_lpd_interconnect/aclk1
ad_mem_hp1_interconnect xxv_eth/tx_clk_out_0 sys_ps8/S_AXI_HP1_FPD
ad_mem_hp1_interconnect xxv_eth/tx_clk_out_0 eth_dma/M_AXI_SG
ad_mem_hp1_interconnect xxv_eth/tx_clk_out_0 eth_dma/M_AXI_MM2S
ad_mem_hp1_interconnect xxv_eth/tx_clk_out_0 eth_dma/M_AXI_S2MM
ad_cpu_interrupt ps-10 mb-10 eth_dma/mm2s_introut
ad_cpu_interrupt ps-11 mb-11 eth_dma/s2mm_introut

# === TEMPORARY RX-path diagnostic ILAs (remove once RX works) ===
# rx_clk_out domain: does the MAC ever emit a frame, and is the FIFO out of reset?
ad_ip_instance system_ila eth_ila_rx [list \
  C_MON_TYPE {MIX} \
  C_NUM_MONITOR_SLOTS {1} \
  C_SLOT_0_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
  C_NUM_OF_PROBES {3} \
  C_DATA_DEPTH {4096} \
]
ad_connect xxv_eth/rx_clk_out_0 eth_ila_rx/clk
connect_bd_intf_net [get_bd_intf_pins xxv_eth/axis_rx_0] [get_bd_intf_pins eth_ila_rx/SLOT_0_AXIS]
ad_connect xxv_eth/stat_rx_block_lock_0 eth_ila_rx/probe0
ad_connect xxv_eth/user_rx_reset_0 eth_ila_rx/probe1
ad_connect eth_rx_rstgen/peripheral_aresetn eth_ila_rx/probe2

# tx_clk domain: FIFO egress toward DMA (slot 0) + known-good TX path for reference
# (slot 1) + DMA descriptor-fetch and S2MM memory-write AXI channels (slots 2,3)
ad_ip_instance system_ila eth_ila_tx [list \
  C_MON_TYPE {INTERFACE} \
  C_NUM_MONITOR_SLOTS {4} \
  C_SLOT_0_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
  C_SLOT_1_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
  C_SLOT_2_INTF_TYPE {xilinx.com:interface:aximm_rtl:1.0} \
  C_SLOT_3_INTF_TYPE {xilinx.com:interface:aximm_rtl:1.0} \
  C_DATA_DEPTH {4096} \
]
ad_connect xxv_eth/tx_clk_out_0 eth_ila_tx/clk
connect_bd_intf_net [get_bd_intf_pins eth_rx_fifo/M_AXIS] [get_bd_intf_pins eth_ila_tx/SLOT_0_AXIS]
connect_bd_intf_net [get_bd_intf_pins eth_tx_fifo/M_AXIS] [get_bd_intf_pins eth_ila_tx/SLOT_1_AXIS]
connect_bd_intf_net [get_bd_intf_pins eth_dma/M_AXI_SG] [get_bd_intf_pins eth_ila_tx/SLOT_2_AXI]
connect_bd_intf_net [get_bd_intf_pins eth_dma/M_AXI_S2MM] [get_bd_intf_pins eth_ila_tx/SLOT_3_AXI]
