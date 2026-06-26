###############################################################################
## Copyright (C) 2019-2025 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################
#
# 10G Ethernet + HARDWARE CHECKSUM OFFLOAD (CSO) on the Genesys ZU-5EV.
# xxv_ethernet MAC+PCS 64-bit BASE-R + axi_mcdma + the AMD CSO example IP
# (tx_csum / csum_rx / cntrl_strm_rd, from the 10G AXI Ethernet Checksum
# Offload Example Design 2022.1, packaged in ./cso_iprepo). Topology mirrors
# that example's config_bd.tcl, adapted to ADI flow + our board:
#   * dedicated 300 MHz clk_wiz drives the MCDMA + CSO datapath (128-bit M_AXI);
#     MAC edges stay on tx_clk_out/rx_clk_out; CDC in the boundary FIFOs.
#   * mcdma c_sg_include_stscntrl_strm=1: TX csum command rides the MM2S CNTRL
#     stream (cntrl_strm_rd -> tx_csum app pins); RX csum status rides the S2MM
#     STS stream (csum_rx/m01 -> S2MM_STS). (This properly FEEDS the status
#     stream that was dangling in the bare-mcdma RX-dead era.)
#   * single channel, NO tdest_mapper/RSS (single TCP flow), NO pkt_overflow
#     (RX is light for the DAQ; can add later if RX overflow shows up).
# Driver already supports it (xlnx,txcsum/rxcsum -> NETIF_F_HW_CSUM/RXCSUM);
# DT must add xlnx,txcsum=<1>, xlnx,rxcsum=<2>, axistream-control-connected.
###############################################################################

# Register the CSO example IP repo. adi_project_create has already opened an
# empty 'system' BD and pinned ip_repo_paths to the ADI library only; the
# catalog can't be rebuilt while a BD is open, so close the empty BD, add the
# repo, rebuild, and recreate the empty BD before building the design.
save_bd_design
close_bd_design [current_bd_design]
set_property ip_repo_paths \
  [concat [get_property ip_repo_paths [current_fileset]] [file normalize ./cso_iprepo]] \
  [current_fileset]
update_ip_catalog -rebuild
open_bd_design [get_files system.bd]

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
# XXV 10G MAC+PCS (GTH Quad_X0Y1, SFP lane X0Y7 - schematic-validated, links)
###############################################################################
ad_ip_instance xxv_ethernet xxv_eth
ad_ip_parameter xxv_eth CONFIG.CORE {Ethernet MAC+PCS/PMA 64-bit}
ad_ip_parameter xxv_eth CONFIG.GT_LOCATION 1
ad_ip_parameter xxv_eth CONFIG.BASE_R_KR {BASE-R}
ad_ip_parameter xxv_eth CONFIG.NUM_OF_CORES 1
ad_ip_parameter xxv_eth CONFIG.GT_REF_CLK_FREQ 156.25
ad_ip_parameter xxv_eth CONFIG.GT_GROUP_SELECT {Quad_X0Y1}
ad_ip_parameter xxv_eth CONFIG.LANE1_GT_LOC {X0Y7}
ad_ip_parameter xxv_eth CONFIG.INCLUDE_AXI4_INTERFACE 1
ad_ip_parameter xxv_eth CONFIG.INCLUDE_STATISTICS_COUNTERS 0

###############################################################################
# 300 MHz datapath clock for the MCDMA + CSO core (from sys_cpu_clk 100 MHz)
###############################################################################
ad_ip_instance clk_wiz eth_clk_wiz
ad_ip_parameter eth_clk_wiz CONFIG.PRIM_IN_FREQ 100.000
ad_ip_parameter eth_clk_wiz CONFIG.CLKOUT1_REQUESTED_OUT_FREQ 150.000
ad_ip_parameter eth_clk_wiz CONFIG.RESET_TYPE ACTIVE_HIGH
ad_ip_parameter eth_clk_wiz CONFIG.USE_LOCKED true
ad_connect sys_cpu_clk eth_clk_wiz/clk_in1
ad_connect sys_rstgen/peripheral_reset eth_clk_wiz/reset

# reset sync for the 300 MHz domain
ad_ip_instance proc_sys_reset eth300_rstgen
ad_connect eth_clk_wiz/clk_out1 eth300_rstgen/slowest_sync_clk
ad_connect sys_ps8/pl_resetn0 eth300_rstgen/ext_reset_in
ad_connect eth_clk_wiz/locked eth300_rstgen/dcm_locked

###############################################################################
# AXI MCDMA (1 ch each way, stscntrl stream ON for CSO, 128-bit memory side)
###############################################################################
ad_ip_instance axi_mcdma eth_mcdma
ad_ip_parameter eth_mcdma CONFIG.c_num_mm2s_channels 1
ad_ip_parameter eth_mcdma CONFIG.c_num_s2mm_channels 1
ad_ip_parameter eth_mcdma CONFIG.c_include_sg 1
ad_ip_parameter eth_mcdma CONFIG.c_sg_include_stscntrl_strm 1
ad_ip_parameter eth_mcdma CONFIG.c_prmry_is_aclk_async 1
ad_ip_parameter eth_mcdma CONFIG.c_sg_length_width 23
ad_ip_parameter eth_mcdma CONFIG.c_addr_width 32
ad_ip_parameter eth_mcdma CONFIG.c_m_axi_mm2s_data_width 128
ad_ip_parameter eth_mcdma CONFIG.c_m_axis_mm2s_tdata_width 64
ad_ip_parameter eth_mcdma CONFIG.c_m_axi_s2mm_data_width 128
ad_ip_parameter eth_mcdma CONFIG.c_s_axis_s2mm_tdata_width 64
ad_ip_parameter eth_mcdma CONFIG.c_mm2s_burst_size 256
ad_ip_parameter eth_mcdma CONFIG.c_s2mm_burst_size 256
ad_ip_parameter eth_mcdma CONFIG.c_mm2s_scheduler 1
ad_ip_parameter eth_mcdma CONFIG.c_include_mm2s_dre 1
ad_ip_parameter eth_mcdma CONFIG.c_include_s2mm_dre 1
ad_ip_parameter eth_mcdma CONFIG.c_enable_multi_intr 1

###############################################################################
# CSO IP (encrypted user IP from the example, validated OOC in 2025.1)
###############################################################################
create_bd_cell -type ip -vlnv user.org:user:tx_csum:1.0       tx_csum
create_bd_cell -type ip -vlnv user.org:user:csum_rx:1.0       csum_rx
create_bd_cell -type ip -vlnv user.org:user:cntrl_strm_rd:1.0 cntrl_strm_rd

###############################################################################
# datapath FIFOs (configs per the example; FIFO_MODE 1)
###############################################################################
# TX data: mcdma MM2S -> tx_csum (300 MHz, sync)
ad_ip_instance axis_data_fifo eth_tx_data_fifo
ad_ip_parameter eth_tx_data_fifo CONFIG.FIFO_DEPTH 8192
ad_ip_parameter eth_tx_data_fifo CONFIG.FIFO_MODE 1
# TX control: mcdma MM2S_CNTRL -> cntrl_strm_rd (300 MHz, sync)
ad_ip_instance axis_data_fifo eth_tx_cntrl_fifo
ad_ip_parameter eth_tx_cntrl_fifo CONFIG.FIFO_DEPTH 256
ad_ip_parameter eth_tx_cntrl_fifo CONFIG.FIFO_MODE 1
# RX status: csum_rx/m01 -> mcdma S2MM_STS (300 MHz, sync)
ad_ip_instance axis_data_fifo eth_rx_sts_fifo
ad_ip_parameter eth_rx_sts_fifo CONFIG.FIFO_DEPTH 256
ad_ip_parameter eth_rx_sts_fifo CONFIG.FIFO_MODE 1
# RX data: csum_rx/m00 -> mcdma S2MM (300 MHz, sync)
# (example used 32768; shrunk to 4096 for the xczu5ev BRAM budget - RX is
#  light for the TX-heavy DAQ. Bump back up + add pkt_overflow if RX drops.)
ad_ip_instance axis_data_fifo eth_rx_data_fifo
ad_ip_parameter eth_rx_data_fifo CONFIG.FIFO_DEPTH 4096
ad_ip_parameter eth_rx_data_fifo CONFIG.FIFO_MODE 1
# RX ingress: MAC axis_rx (rx_clk) -> csum_rx (300 MHz) : async CDC FIFO
ad_ip_instance axis_data_fifo eth_rx_ingress_fifo
ad_ip_parameter eth_rx_ingress_fifo CONFIG.FIFO_DEPTH 4096
ad_ip_parameter eth_rx_ingress_fifo CONFIG.FIFO_MODE 1
ad_ip_parameter eth_rx_ingress_fifo CONFIG.IS_ACLK_ASYNC 1

###############################################################################
# reset inverters (util_vector_logic NOT, 1-bit) - reference reset topology
###############################################################################
foreach inv {gt_datapath_rst dma_tx_rst dma_rx_rst tx_rst_n rx_rst_n} {
  ad_ip_instance util_vector_logic $inv
  ad_ip_parameter $inv CONFIG.C_OPERATION not
  ad_ip_parameter $inv CONFIG.C_SIZE 1
}

# GT outclk sel = 3'b101 (gtwizard requirement); tx preamble tie-off
ad_ip_instance xlconstant outclksel_const
ad_ip_parameter outclksel_const CONFIG.CONST_WIDTH 3
ad_ip_parameter outclksel_const CONFIG.CONST_VAL 5
ad_ip_instance xlconstant preamble_const
ad_ip_parameter preamble_const CONFIG.CONST_WIDTH 56
ad_ip_parameter preamble_const CONFIG.CONST_VAL 0

###############################################################################
# clocking
###############################################################################
# sys_cpu_clk (100): MAC dclk + lite, mcdma lite (async to engines)
ad_connect sys_cpu_clk xxv_eth/dclk
ad_connect sys_cpu_clk xxv_eth/s_axi_aclk_0
ad_connect sys_cpu_clk eth_mcdma/s_axi_lite_aclk
# eth_clk300: mcdma engines + SG, CSO blocks, datapath FIFOs (300-side)
ad_connect eth_clk_wiz/clk_out1 eth_mcdma/m_axi_sg_aclk
ad_connect eth_clk_wiz/clk_out1 eth_mcdma/m_axi_mm2s_aclk
ad_connect eth_clk_wiz/clk_out1 eth_mcdma/m_axi_s2mm_aclk
ad_connect eth_clk_wiz/clk_out1 csum_rx/s00_axis_aclk
ad_connect eth_clk_wiz/clk_out1 csum_rx/m00_axis_aclk
ad_connect eth_clk_wiz/clk_out1 csum_rx/m01_axis_aclk
ad_connect eth_clk_wiz/clk_out1 cntrl_strm_rd/clk
ad_connect eth_clk_wiz/clk_out1 tx_csum/s00_axis_aclk
ad_connect eth_clk_wiz/clk_out1 eth_tx_data_fifo/s_axis_aclk
ad_connect eth_clk_wiz/clk_out1 eth_tx_cntrl_fifo/s_axis_aclk
ad_connect eth_clk_wiz/clk_out1 eth_rx_sts_fifo/s_axis_aclk
ad_connect eth_clk_wiz/clk_out1 eth_rx_data_fifo/s_axis_aclk
ad_connect eth_clk_wiz/clk_out1 eth_rx_ingress_fifo/m_axis_aclk
# MAC clocks at the boundary
ad_connect xxv_eth/tx_clk_out_0 tx_csum/m00_axis_aclk
ad_connect xxv_eth/rx_clk_out_0 xxv_eth/rx_core_clk_0
ad_connect xxv_eth/rx_clk_out_0 eth_rx_ingress_fifo/s_axis_aclk

###############################################################################
# resets
###############################################################################
set r300 eth300_rstgen/peripheral_aresetn
# mcdma axi_resetn is associated with the (100 MHz) lite clock -> drive from
# sys_cpu_resetn to avoid a reset-domain crossing (BD 41-1344). The engines'
# resets are derived internally (c_prmry_is_aclk_async=1).
ad_connect sys_cpu_resetn eth_mcdma/axi_resetn
ad_connect $r300 csum_rx/s00_axis_aresetn
ad_connect $r300 csum_rx/m00_axis_aresetn
ad_connect $r300 csum_rx/m01_axis_aresetn
ad_connect $r300 cntrl_strm_rd/resetn
ad_connect $r300 tx_csum/s00_axis_aresetn
ad_connect $r300 eth_tx_data_fifo/s_axis_aresetn
ad_connect $r300 eth_tx_cntrl_fifo/s_axis_aresetn
ad_connect $r300 eth_rx_sts_fifo/s_axis_aresetn
ad_connect $r300 eth_rx_data_fifo/s_axis_aresetn
ad_connect sys_cpu_resetn xxv_eth/s_axi_aresetn_0
ad_connect sys_rstgen/peripheral_reset xxv_eth/sys_reset
# gtwiz datapath reset = NOT(pl_resetn0)
ad_connect sys_ps8/pl_resetn0 gt_datapath_rst/Op1
ad_connect gt_datapath_rst/Res xxv_eth/gtwiz_reset_tx_datapath_0
ad_connect gt_datapath_rst/Res xxv_eth/gtwiz_reset_rx_datapath_0
# MAC tx/rx_reset = NOT(mcdma per-ch reset_out_n)
ad_connect eth_mcdma/mm2s_prmry_reset_out_n dma_tx_rst/Op1
ad_connect dma_tx_rst/Res xxv_eth/tx_reset_0
ad_connect eth_mcdma/s2mm_prmry_reset_out_n dma_rx_rst/Op1
ad_connect dma_rx_rst/Res xxv_eth/rx_reset_0
# MAC-edge FIFO/csum resets = NOT(MAC user_*_reset)
ad_connect xxv_eth/user_tx_reset_0 tx_rst_n/Op1
ad_connect tx_rst_n/Res tx_csum/m00_axis_aresetn
ad_connect xxv_eth/user_rx_reset_0 rx_rst_n/Op1
ad_connect rx_rst_n/Res eth_rx_ingress_fifo/s_axis_aresetn

###############################################################################
# control tie-offs
###############################################################################
ad_connect outclksel_const/dout xxv_eth/txoutclksel_in_0
ad_connect outclksel_const/dout xxv_eth/rxoutclksel_in_0
ad_connect preamble_const/dout xxv_eth/tx_preamblein_0
ad_connect xxv_eth/ctl_tx_send_idle_0 GND
ad_connect xxv_eth/ctl_tx_send_lfi_0 GND
ad_connect xxv_eth/ctl_tx_send_rfi_0 GND
ad_connect xxv_eth/qpllreset_in_0 GND

###############################################################################
# datapath: TX  mcdma MM2S -> data fifo -> tx_csum -> MAC
#                mcdma MM2S_CNTRL -> cntrl fifo -> cntrl_strm_rd -> tx_csum app
#           RX  MAC -> ingress fifo -> csum_rx -> {data->S2MM, sts->S2MM_STS}
###############################################################################
connect_bd_intf_net [get_bd_intf_pins eth_mcdma/M_AXIS_MM2S]  [get_bd_intf_pins eth_tx_data_fifo/S_AXIS]
connect_bd_intf_net [get_bd_intf_pins eth_tx_data_fifo/M_AXIS] [get_bd_intf_pins tx_csum/s00_axis]
connect_bd_intf_net [get_bd_intf_pins tx_csum/m00_axis]        [get_bd_intf_pins xxv_eth/axis_tx_0]
connect_bd_intf_net [get_bd_intf_pins eth_mcdma/M_AXIS_CNTRL] [get_bd_intf_pins eth_tx_cntrl_fifo/S_AXIS]
connect_bd_intf_net [get_bd_intf_pins eth_tx_cntrl_fifo/M_AXIS] [get_bd_intf_pins cntrl_strm_rd/S_CNTRL_AXIS]

connect_bd_intf_net [get_bd_intf_pins xxv_eth/axis_rx_0]        [get_bd_intf_pins eth_rx_ingress_fifo/S_AXIS]
connect_bd_intf_net [get_bd_intf_pins eth_rx_ingress_fifo/M_AXIS] [get_bd_intf_pins csum_rx/s00_axis]
connect_bd_intf_net [get_bd_intf_pins csum_rx/m00_axis]        [get_bd_intf_pins eth_rx_data_fifo/S_AXIS]
connect_bd_intf_net [get_bd_intf_pins eth_rx_data_fifo/M_AXIS] [get_bd_intf_pins eth_mcdma/S_AXIS_S2MM]
connect_bd_intf_net [get_bd_intf_pins csum_rx/m01_axis]        [get_bd_intf_pins eth_rx_sts_fifo/S_AXIS]
connect_bd_intf_net [get_bd_intf_pins eth_rx_sts_fifo/M_AXIS]  [get_bd_intf_pins eth_mcdma/S_AXIS_STS]

# TX csum command/handshake (single-bit app nets)
ad_connect cntrl_strm_rd/axi_flag    tx_csum/axi_flag_app
ad_connect cntrl_strm_rd/csum_begin  tx_csum/csum_begin_app
ad_connect cntrl_strm_rd/csum_cntrl  tx_csum/csum_cntrl_app
ad_connect cntrl_strm_rd/csum_init   tx_csum/csum_init_app
ad_connect cntrl_strm_rd/csum_insert tx_csum/csum_insert_app
ad_connect tx_csum/csumVld           cntrl_strm_rd/csum_done

# diagnostics: dump actual pins of the new cells into the build log
foreach c {xxv_eth tx_csum csum_rx cntrl_strm_rd eth_mcdma} {
  foreach p [get_bd_pins -of [get_bd_cells $c]] { puts "PINDUMP $c: $p" }
  foreach p [get_bd_intf_pins -of [get_bd_cells $c]] { puts "INTFDUMP $c: $p [get_property VLNV $p]" }
}

###############################################################################
# external GT + refclk ports (individual-pin style, builds in 2025.1)
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
# register maps + coherent DMA memory (HPC0 @ 300 MHz) + per-channel interrupts
###############################################################################
ad_cpu_interconnect 0x84C00000 xxv_eth s_axi_0
ad_cpu_interconnect 0x84C10000 eth_mcdma S_AXI_LITE

ad_mem_hpc0_interconnect eth_clk_wiz/clk_out1 sys_ps8/S_AXI_HPC0_FPD
ad_mem_hpc0_interconnect eth_clk_wiz/clk_out1 eth_mcdma/M_AXI_SG
ad_mem_hpc0_interconnect eth_clk_wiz/clk_out1 eth_mcdma/M_AXI_MM2S
ad_mem_hpc0_interconnect eth_clk_wiz/clk_out1 eth_mcdma/M_AXI_S2MM

ad_cpu_interrupt ps-10 mb-10 eth_mcdma/mm2s_ch1_introut
ad_cpu_interrupt ps-11 mb-11 eth_mcdma/s2mm_ch1_introut
