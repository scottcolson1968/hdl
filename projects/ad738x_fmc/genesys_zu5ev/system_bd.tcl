###############################################################################
## Copyright (C) 2019-2025 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################
#
# MCDMA variant of the 10G Ethernet subsystem, modelled on the proven GUI-built
# reference design (C:/share/ad738x_fmc/gzu_5ev, built to bitstream 2025-05-23;
# bd tcl at C:/share/ad738x_fmc_gzu_5ev.tcl). Replaces the axi_dma path that
# never completed RX descriptors. Key departures from system_bd.tcl (axi_dma):
#   * axi_mcdma (1 mm2s + 1 s2mm ch, multi_intr) instead of axi_dma
#   * c_prmry_is_aclk_async = 1 (mcdma HONORS it; axi_dma silently reverted it)
#   * split datapath clocks: SG+lite on sys_cpu_clk, MM2S on tx_clk, S2MM on
#     rx_clk -- the HPC0 smartconnect does all the CDC (3 clocks)
#   * coherent HPC0 + low DDR + 32-bit addressing (was HP1 + 40-bit)
#   * synchronous store-and-forward FIFOs (no async fifo; CDC is in the SC)
#   * INCLUDE_STATISTICS_COUNTERS 0 -> no tick register -> avoids the 0x2B0 wedge
#   * reference reset topology (mcdma reset_out -> MAC tx/rx_reset, etc.)
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
# 10G Ethernet over SFP+ : xxv_ethernet MAC+PCS 64-bit BASE-R + axi_mcdma.
# GTH Quad_X0Y1, SFP lane X0Y7 (schematic-validated; this lane gave real
# RX block-lock on hardware, so the GT is correct -- the RX failure was the
# DMA, not the transceiver). NB: the reference design uses X0Y4; keeping X0Y7
# because it is the lane proven to link on this board.
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
# stats OFF: no statistics tick register => the 0x2B0 TICK write that hard-wedges
# the board no longer exists, and the reference proves RX works without it.
ad_ip_parameter xxv_eth CONFIG.INCLUDE_STATISTICS_COUNTERS 0

###############################################################################
# AXI MultiChannel DMA (single channel each way). Params mirror the reference
# mcdma .xci exactly.
###############################################################################
ad_ip_instance axi_mcdma eth_mcdma
ad_ip_parameter eth_mcdma CONFIG.c_num_mm2s_channels 1
ad_ip_parameter eth_mcdma CONFIG.c_num_s2mm_channels 1
ad_ip_parameter eth_mcdma CONFIG.c_include_sg 1
ad_ip_parameter eth_mcdma CONFIG.c_sg_include_stscntrl_strm 0
# mcdma honors the async-aclk param (unlike axi_dma, where it reverted to 0 and
# broke the sys_cpu_clk <-> tx/rx_clk crossing). lite+SG run on sys_cpu_clk,
# the engines on the MAC tx/rx clocks; the HPC0 smartconnect bridges them.
ad_ip_parameter eth_mcdma CONFIG.c_prmry_is_aclk_async 1
ad_ip_parameter eth_mcdma CONFIG.c_sg_length_width 23
ad_ip_parameter eth_mcdma CONFIG.c_addr_width 32
ad_ip_parameter eth_mcdma CONFIG.c_m_axi_mm2s_data_width 64
ad_ip_parameter eth_mcdma CONFIG.c_m_axis_mm2s_tdata_width 64
ad_ip_parameter eth_mcdma CONFIG.c_m_axi_s2mm_data_width 64
ad_ip_parameter eth_mcdma CONFIG.c_s_axis_s2mm_tdata_width 64
ad_ip_parameter eth_mcdma CONFIG.c_mm2s_burst_size 256
ad_ip_parameter eth_mcdma CONFIG.c_s2mm_burst_size 256
ad_ip_parameter eth_mcdma CONFIG.c_include_mm2s_dre 1
ad_ip_parameter eth_mcdma CONFIG.c_include_s2mm_dre 1
ad_ip_parameter eth_mcdma CONFIG.c_enable_multi_intr 1

# synchronous store-and-forward FIFOs (single clock domain each):
#   tx fifo entirely in tx_clk (mcdma MM2S -> MAC), rx fifo entirely in rx_clk
#   (MAC -> mcdma S2MM). The clock crossing to the CPU/memory domain happens
#   inside the HPC0 smartconnect, not here.
ad_ip_instance axis_data_fifo eth_tx_fifo
ad_ip_parameter eth_tx_fifo CONFIG.FIFO_DEPTH 8192
ad_ip_parameter eth_tx_fifo CONFIG.FIFO_MODE 2
ad_ip_instance axis_data_fifo eth_rx_fifo
ad_ip_parameter eth_rx_fifo CONFIG.FIFO_DEPTH 8192
ad_ip_parameter eth_rx_fifo CONFIG.FIFO_MODE 2
ad_ip_parameter eth_rx_fifo CONFIG.HAS_RD_DATA_COUNT 1

# inverters (util_vector_logic, 1-bit NOT) for the reference reset topology
ad_ip_instance util_vector_logic gt_datapath_rst
ad_ip_parameter gt_datapath_rst CONFIG.C_OPERATION not
ad_ip_parameter gt_datapath_rst CONFIG.C_SIZE 1
ad_ip_instance util_vector_logic dma_tx_rst
ad_ip_parameter dma_tx_rst CONFIG.C_OPERATION not
ad_ip_parameter dma_tx_rst CONFIG.C_SIZE 1
ad_ip_instance util_vector_logic dma_rx_rst
ad_ip_parameter dma_rx_rst CONFIG.C_OPERATION not
ad_ip_parameter dma_rx_rst CONFIG.C_SIZE 1
ad_ip_instance util_vector_logic tx_rst_n
ad_ip_parameter tx_rst_n CONFIG.C_OPERATION not
ad_ip_parameter tx_rst_n CONFIG.C_SIZE 1
ad_ip_instance util_vector_logic rx_rst_n
ad_ip_parameter rx_rst_n CONFIG.C_OPERATION not
ad_ip_parameter rx_rst_n CONFIG.C_SIZE 1

# GT output clock selects: MUST be 3'b101 per gtwizard exdes ("do not change").
ad_ip_instance xlconstant outclksel_const
ad_ip_parameter outclksel_const CONFIG.CONST_WIDTH 3
ad_ip_parameter outclksel_const CONFIG.CONST_VAL 5
# tx preamble tie-off (56-bit 0), as in the reference
ad_ip_instance xlconstant preamble_const
ad_ip_parameter preamble_const CONFIG.CONST_WIDTH 56
ad_ip_parameter preamble_const CONFIG.CONST_VAL 0

###############################################################################
# clocking
###############################################################################
# sys_cpu_clk (100 MHz): MAC dclk + AXI-lite, mcdma lite + SG master
ad_connect sys_cpu_clk xxv_eth/dclk
ad_connect sys_cpu_clk xxv_eth/s_axi_aclk_0
ad_connect sys_cpu_clk eth_mcdma/s_axi_lite_aclk
ad_connect sys_cpu_clk eth_mcdma/m_axi_sg_aclk
# tx_clk_out (156.25): MAC tx, tx fifo, mcdma MM2S engine
ad_connect xxv_eth/tx_clk_out_0 eth_tx_fifo/s_axis_aclk
ad_connect xxv_eth/tx_clk_out_0 eth_mcdma/m_axi_mm2s_aclk
# rx_clk_out (recovered): MAC rx core, rx fifo, mcdma S2MM engine
ad_connect xxv_eth/rx_clk_out_0 xxv_eth/rx_core_clk_0
ad_connect xxv_eth/rx_clk_out_0 eth_rx_fifo/s_axis_aclk
ad_connect xxv_eth/rx_clk_out_0 eth_mcdma/m_axi_s2mm_aclk

###############################################################################
# resets (mirrors the reference topology)
###############################################################################
ad_connect sys_cpu_resetn xxv_eth/s_axi_aresetn_0
ad_connect sys_cpu_resetn eth_mcdma/axi_resetn
ad_connect sys_rstgen/peripheral_reset xxv_eth/sys_reset
# gtwiz tx/rx datapath reset = NOT(pl_resetn0): a real reset pulse at startup
ad_connect sys_ps8/pl_resetn0 gt_datapath_rst/Op1
ad_connect gt_datapath_rst/Res xxv_eth/gtwiz_reset_tx_datapath_0
ad_connect gt_datapath_rst/Res xxv_eth/gtwiz_reset_rx_datapath_0
# MAC tx/rx_reset (active-high) = NOT(mcdma per-channel reset_out_n)
ad_connect eth_mcdma/mm2s_prmry_reset_out_n dma_tx_rst/Op1
ad_connect dma_tx_rst/Res xxv_eth/tx_reset_0
ad_connect eth_mcdma/s2mm_prmry_reset_out_n dma_rx_rst/Op1
ad_connect dma_rx_rst/Res xxv_eth/rx_reset_0
# fifo aresetn (active-low) = NOT(MAC user_tx/rx_reset, active-high)
ad_connect xxv_eth/user_tx_reset_0 tx_rst_n/Op1
ad_connect tx_rst_n/Res eth_tx_fifo/s_axis_aresetn
ad_connect xxv_eth/user_rx_reset_0 rx_rst_n/Op1
ad_connect rx_rst_n/Res eth_rx_fifo/s_axis_aresetn

###############################################################################
# control tie-offs
###############################################################################
ad_connect outclksel_const/dout xxv_eth/txoutclksel_in_0
ad_connect outclksel_const/dout xxv_eth/rxoutclksel_in_0
ad_connect preamble_const/dout xxv_eth/tx_preamblein_0
ad_connect xxv_eth/ctl_tx_send_idle_0 GND
ad_connect xxv_eth/ctl_tx_send_lfi_0 GND
ad_connect xxv_eth/ctl_tx_send_rfi_0 GND
# qpllreset: reference drives this from an axi_gpio (default held, SW releases).
# Tied low here so the QPLL is free to lock without a gpio driver. If link
# fails to come up, switch to a SW-controlled gpio like the reference.
ad_connect xxv_eth/qpllreset_in_0 GND

###############################################################################
# datapath: mcdma MM2S -> tx fifo -> MAC ; MAC RX -> rx fifo -> mcdma S2MM
###############################################################################
ad_connect eth_mcdma/M_AXIS_MM2S eth_tx_fifo/S_AXIS
ad_connect eth_tx_fifo/M_AXIS xxv_eth/axis_tx_0
ad_connect xxv_eth/axis_rx_0 eth_rx_fifo/S_AXIS
ad_connect eth_rx_fifo/M_AXIS eth_mcdma/S_AXIS_S2MM

# diagnostics: dump the IP's actual pins/intf into the build log (verify the
# GT port + reset pin names match this script on the first build)
puts "PINDUMP-GT_LOCATION: [get_property CONFIG.GT_LOCATION [get_bd_cells xxv_eth]]"
foreach pdump [get_bd_pins -of [get_bd_cells xxv_eth]] { puts "PINDUMP: $pdump" }
foreach pdump [get_bd_intf_pins -of [get_bd_cells xxv_eth]] { puts "INTFDUMP: $pdump [get_property VLNV $pdump]" }

###############################################################################
# external GT + refclk ports (individual-pin style, proven to build in this
# 2025.1 tree). If the 2025.1 xxv presents gt_serial_port/gt_ref_clk interface
# ports instead, adapt per the PINDUMP output above.
###############################################################################
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

###############################################################################
# register maps + coherent DMA memory path (HPC0) + per-channel interrupts
###############################################################################
ad_cpu_interconnect 0x84C00000 xxv_eth s_axi_0
ad_cpu_interconnect 0x84C10000 eth_mcdma S_AXI_LITE

# all three mcdma masters share one HPC0 smartconnect; each on its own clock so
# the SC inserts the CDC converters (this is the structural RX fix).
ad_mem_hpc0_interconnect sys_cpu_clk sys_ps8/S_AXI_HPC0_FPD
ad_mem_hpc0_interconnect sys_cpu_clk eth_mcdma/M_AXI_SG
ad_mem_hpc0_interconnect xxv_eth/tx_clk_out_0 eth_mcdma/M_AXI_MM2S
ad_mem_hpc0_interconnect xxv_eth/rx_clk_out_0 eth_mcdma/M_AXI_S2MM

ad_cpu_interrupt ps-10 mb-10 eth_mcdma/mm2s_ch1_introut
ad_cpu_interrupt ps-11 mb-11 eth_mcdma/s2mm_ch1_introut
