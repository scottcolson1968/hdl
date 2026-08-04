###############################################################################
## Copyright (C) 2024-2025 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
##
## Wildcat2 block design : EVAL-AD4080-FMC on Digilent Genesys ZU-5EV.
##
## Structure (mirrors projects/ad738x_fmc/genesys_zu5ev/system_bd.tcl):
##   1. Genesys ZU-5EV carrier   (sys_ps8, EMIO SPI0/SPI1, EMIO GPIO, sysid)
##   2. AD4080 LVDS front-end    (axi_ad408x + axi_clock_monitor + axi_dmac)
##   3. 10G Ethernet backhaul    (xxv_ethernet + axi_mcdma) -- reused verbatim
##                                from the proven Wildcat port.
##
## NOTE: the AD4080 front-end here is adapted from ../common/ad4080_fmc_evb_bd.tcl,
## which targets the ZedBoard and HARD-CODES sys_ps7 / S_AXI_HP1. That file is
## therefore NOT sourced directly; the front-end is inlined below with the PS8 /
## coherent-memory wiring the Genesys carrier requires.
###############################################################################

source $ad_hdl_dir/projects/common/genesys-zu5ev/genesys_zu5ev_system_bd.tcl
source $ad_hdl_dir/projects/scripts/adi_pd.tcl

# NOTE: the license-free 10G custom IPs (open_mac_10g/xxv_shim/tx_csum_open) are
# staged in $ad_hdl_dir/library, so adi_project_create's update_ip_catalog
# registers them before it builds this BD. The splices at the end then find them.

set ADC_N_BITS $ad_project_params(ADC_N_BITS)
if {$ADC_N_BITS <= 16} {
    set DMA_DATA_WIDTH_SRC 16
} else {
    set DMA_DATA_WIDTH_SRC 32
}

###############################################################################
# 1. AD4080 LVDS front-end (adapted from ../common/ad4080_fmc_evb_bd.tcl)
###############################################################################

# ad4080 interface ports (brought to system_top via the FMC LPC connector)
create_bd_port -dir I dco_p
create_bd_port -dir I dco_n
create_bd_port -dir I da_p
create_bd_port -dir I da_n
create_bd_port -dir I db_p
create_bd_port -dir I db_n
create_bd_port -dir I sync_n
create_bd_port -dir I filter_data_ready_n
create_bd_port -dir I fpga_ref_clk
create_bd_port -dir I fpga_100_clk

# Clock monitor. Counters are readable from Linux at 0x80050000; note the
# register map is WORD-indexed, so clk_mon_count[n] lives at BYTE offset
# 0x40 + 4*n (NOT 0x10 + 4*n).
#
#   clock_0 = fpga_ref_clk  (LA01_CC)      0x40  } diagnostic only - nothing in
#   clock_1 = fpga_100_clk  (CLK1_M2C)     0x44  } the datapath depends on these
#   clock_2 = adc_clk = DCO/2              0x48  <-- ADDED 2026-08-03
#
# clock_2 is the point of this change. adc_clk is the AD4080 DCO after
# axi_ad408x's IBUFGDS + BUFGCE_DIV(2) (ad408x_phy.v), so a non-zero count here
# proves the ADC is actually clocking data out, and its value gives the real DCO
# frequency (= 2 x measured). Until now the monitor watched only the two
# diagnostic clocks and could say NOTHING about why
# "Data alignment process failed" - the alignment FSM is clocked by DCO.
ad_ip_instance axi_clock_monitor ad4080_clock_monitor
ad_ip_parameter ad4080_clock_monitor CONFIG.NUM_OF_CLOCKS 3
ad_ip_parameter ad4080_clock_monitor CONFIG.DIV_RATE 4
ad_connect fpga_ref_clk  ad4080_clock_monitor/clock_0
ad_connect fpga_100_clk  ad4080_clock_monitor/clock_1
# clock_2 is connected after axi_ad4080_adc is instantiated (see below).

# axi_ad408x LVDS receiver
ad_ip_instance axi_ad408x axi_ad4080_adc
ad_ip_parameter axi_ad4080_adc CONFIG.ADC_N_BITS $ADC_N_BITS

# rx dma
ad_ip_instance axi_dmac axi_ad4080_dma
ad_ip_parameter axi_ad4080_dma CONFIG.DMA_TYPE_SRC 2
ad_ip_parameter axi_ad4080_dma CONFIG.DMA_TYPE_DEST 0
ad_ip_parameter axi_ad4080_dma CONFIG.CYCLIC 0
ad_ip_parameter axi_ad4080_dma CONFIG.SYNC_TRANSFER_START 0
ad_ip_parameter axi_ad4080_dma CONFIG.AXI_SLICE_SRC 1
ad_ip_parameter axi_ad4080_dma CONFIG.AXI_SLICE_DEST 0
ad_ip_parameter axi_ad4080_dma CONFIG.DMA_2D_TRANSFER 0
ad_ip_parameter axi_ad4080_dma CONFIG.DMA_DATA_WIDTH_SRC $DMA_DATA_WIDTH_SRC
ad_ip_parameter axi_ad4080_dma CONFIG.DMA_DATA_WIDTH_DEST 64

# interface -> axi_ad408x
ad_connect dco_p                axi_ad4080_adc/dclk_in_p
ad_connect dco_n                axi_ad4080_adc/dclk_in_n
ad_connect da_p                 axi_ad4080_adc/data_a_in_p
ad_connect da_n                 axi_ad4080_adc/data_a_in_n
ad_connect db_p                 axi_ad4080_adc/data_b_in_p
ad_connect db_n                 axi_ad4080_adc/data_b_in_n
ad_connect sync_n               axi_ad4080_adc/sync_n
# CNV is unused inside axi_ad408x (cnv_in_p/n is a dangling IP port; framing is
# reconstructed from sync_n + DCO + filter_data_ready). On the eval, CNV is just
# an alias of FPGACLK (FMC_CLK1_M2C), monitored as fpga_100_clk below. Tie the
# dead IP inputs to GND rather than routing a pin.
ad_connect GND                  axi_ad4080_adc/cnv_in_p
ad_connect GND                  axi_ad4080_adc/cnv_in_n
ad_connect filter_data_ready_n  axi_ad4080_adc/filter_data_ready_n
ad_connect $sys_iodelay_clk     axi_ad4080_adc/delay_clk

# DCO-derived recovered clock -> clock monitor input 2 (see the banner above).
ad_connect axi_ad4080_adc/adc_clk ad4080_clock_monitor/clock_2

# datapath
ad_connect axi_ad4080_adc/adc_data  axi_ad4080_dma/fifo_wr_din
ad_connect axi_ad4080_adc/adc_valid axi_ad4080_dma/fifo_wr_en
ad_connect axi_ad4080_adc/adc_dovf  axi_ad4080_dma/fifo_wr_overflow
ad_connect axi_ad4080_adc/adc_clk   axi_ad4080_dma/fifo_wr_clk
ad_connect $sys_cpu_resetn          axi_ad4080_dma/m_dest_axi_aresetn

###############################################################################
# DEBUG ILA on the AD4080 LVDS front end (adc_clk = DCO/2 domain).
#
# Needs Vivado Hardware Manager over JTAG - it is NOT readable from Linux. The
# clock monitor above is the remote-readable instrument; this is the next layer
# down, for once DCO is known to be alive.
#
# NB an ILA clocked by adc_clk cannot sample if DCO is dead - in that case it
# simply never triggers, which is itself the answer (and the clock monitor
# confirms it). Trigger suggestion: adc_valid rising, or adc_rst falling to
# catch the window where the alignment FSM runs.
#
# Probe widths MUST match the connected nets or the BD fails to validate.
# adc_data is 32 bits because ADC_N_BITS=20 (>16) in axi_ad408x.
###############################################################################
ad_ip_instance ila ad4080_ila {
  C_NUM_OF_PROBES    13
  C_DATA_DEPTH       4096
  C_INPUT_PIPE_STAGES 1
  C_PROBE0_WIDTH     32
  C_PROBE1_WIDTH     1
  C_PROBE2_WIDTH     1
  C_PROBE3_WIDTH     1
  C_PROBE4_WIDTH     1
  C_PROBE5_WIDTH     1
  C_PROBE6_WIDTH     1
  C_PROBE7_WIDTH     2
  C_PROBE8_WIDTH     18
  C_PROBE9_WIDTH     8
  C_PROBE10_WIDTH    20
  C_PROBE11_WIDTH    20
  C_PROBE12_WIDTH    16
}
ad_connect axi_ad4080_adc/adc_clk    ad4080_ila/clk
ad_connect axi_ad4080_adc/adc_data   ad4080_ila/probe0
ad_connect axi_ad4080_adc/adc_valid  ad4080_ila/probe1
ad_connect axi_ad4080_adc/adc_enable ad4080_ila/probe2
ad_connect axi_ad4080_adc/adc_rst    ad4080_ila/probe3
ad_connect axi_ad4080_adc/adc_dovf   ad4080_ila/probe4
# sync_n and filter_data_ready_n are asynchronous to adc_clk; sampled here for
# observation only (expect occasional metastable edges - that is fine).
ad_connect sync_n                    ad4080_ila/probe5
ad_connect filter_data_ready_n       ad4080_ila/probe6
# IDELAY control path: probe7 = load request from up_delay_cntrl,
# probe8 = CNTVALUEOUT readback. If probe7 never pulses the request is not being
# issued; if it pulses while probe8 stays constant the load is not taking effect.
ad_connect axi_ad4080_adc/dbg_up_dld    ad4080_ila/probe7
ad_connect axi_ad4080_adc/dbg_up_drdata ad4080_ila/probe8
# phy internals: probe9 = raw deserializer output (serdes_data_8),
# probe10 = after the 4/8->20 packer, probe11 = after the barrel shifter
# (this is what is compared against 0xAC5D6), probe12 = state bits with
# serdes_reset_s in bit 0. Zero on probe9 with bit0 of probe12 low means
# the ADC is not driving the lanes at all.
ad_connect axi_ad4080_adc/dbg_serdes_data ad4080_ila/probe9
ad_connect axi_ad4080_adc/dbg_packed      ad4080_ila/probe10
ad_connect axi_ad4080_adc/dbg_shifted     ad4080_ila/probe11
ad_connect axi_ad4080_adc/dbg_state       ad4080_ila/probe12

# register maps -- this carrier reaches the PL via M_AXI_HPM0_LPD (the ADI
# headless genesys bd enables GP2/LPD only), whose ONLY aperture is
# 0x8000_0000..0x9FFF_FFFF [512M]. The ADI ad4080 reference 0x44Axxxxx (Zynq-7000)
# and the deployed 0xA0xxxxxx (that came from the FPD-based GUI build) are both
# invalid here. Use 0x80xxxxxx, mirroring the deployed offsets with an 0x80 base.
ad_cpu_interconnect 0x80000000 axi_ad4080_dma
ad_cpu_interconnect 0x80010000 axi_ad4080_adc
ad_cpu_interconnect 0x80050000 ad4080_clock_monitor

# ADC DMA to memory via HP0 (kept off the 10G HPC0 coherent path).
# Genesys carrier disables S_AXI GP ports; ad_mem_hp0_interconnect re-enables it.
ad_mem_hp0_interconnect $sys_cpu_clk sys_ps8/S_AXI_HP0_FPD
ad_mem_hp0_interconnect $sys_cpu_clk axi_ad4080_dma/m_dest_axi
ad_ip_parameter sys_ps8 CONFIG.PSU__USE__S_AXI_GP2 1

ad_cpu_interrupt ps-13 mb-12 axi_ad4080_dma/irq

###############################################################################
# RGB status LED (LD5): dedicated 3-bit all-outputs AXI GPIO -> rgb_led_o,
# wired to ld5_r/g/b in system_top.v. ADI ad_cpu_interconnect style (the copied
# rgb_led_gpio.tcl targets the GUI-build axi_smc and cannot be sourced here).
# The PS EMIO GPIO has no spare outputs, hence a dedicated memory-mapped GPIO.
###############################################################################
ad_ip_instance axi_gpio axi_gpio_rgb_led
ad_ip_parameter axi_gpio_rgb_led CONFIG.C_ALL_OUTPUTS 1
ad_ip_parameter axi_gpio_rgb_led CONFIG.C_GPIO_WIDTH 3
create_bd_port -dir O -from 2 -to 0 rgb_led_o
ad_connect axi_gpio_rgb_led/gpio_io_o rgb_led_o
ad_cpu_interconnect 0x80080000 axi_gpio_rgb_led

###############################################################################
# system ID
###############################################################################
ad_ip_parameter axi_sysid_0 CONFIG.ROM_ADDR_BITS 9
ad_ip_parameter rom_sys_0 CONFIG.PATH_TO_FILE "$mem_init_sys_file_path/mem_init_sys.txt"
ad_ip_parameter rom_sys_0 CONFIG.ROM_ADDR_BITS 9
sysid_gen_sys_init_file "ADC_N_BITS=$ADC_N_BITS"

###############################################################################
# 2. 10G Ethernet over SFP+ : xxv_ethernet MAC+PCS 64-bit BASE-R + axi_mcdma.
#    Reused verbatim from projects/ad738x_fmc/genesys_zu5ev/system_bd.tcl
#    (the axi_mcdma variant proven to give RX block-lock on this board). The
#    open-MAC + TX-checksum-offload splice (see open_mac_splice.tcl /
#    tx_csum_splice.tcl) is applied post-build exactly as in Wildcat.
#    GTH Quad_X0Y1, SFP lane X0Y7.
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

ad_ip_instance axi_mcdma eth_mcdma
ad_ip_parameter eth_mcdma CONFIG.c_num_mm2s_channels 1
ad_ip_parameter eth_mcdma CONFIG.c_num_s2mm_channels 1
ad_ip_parameter eth_mcdma CONFIG.c_include_sg 1
ad_ip_parameter eth_mcdma CONFIG.c_sg_include_stscntrl_strm 0
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

ad_ip_instance axis_data_fifo eth_tx_fifo
ad_ip_parameter eth_tx_fifo CONFIG.FIFO_DEPTH 8192
ad_ip_parameter eth_tx_fifo CONFIG.FIFO_MODE 2
ad_ip_instance axis_data_fifo eth_rx_fifo
ad_ip_parameter eth_rx_fifo CONFIG.FIFO_DEPTH 8192
ad_ip_parameter eth_rx_fifo CONFIG.FIFO_MODE 2
ad_ip_parameter eth_rx_fifo CONFIG.HAS_RD_DATA_COUNT 1

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

ad_ip_instance xlconstant outclksel_const
ad_ip_parameter outclksel_const CONFIG.CONST_WIDTH 3
ad_ip_parameter outclksel_const CONFIG.CONST_VAL 5
ad_ip_instance xlconstant preamble_const
ad_ip_parameter preamble_const CONFIG.CONST_WIDTH 56
ad_ip_parameter preamble_const CONFIG.CONST_VAL 0

# clocking
ad_connect sys_cpu_clk xxv_eth/dclk
ad_connect sys_cpu_clk xxv_eth/s_axi_aclk_0
ad_connect sys_cpu_clk eth_mcdma/s_axi_lite_aclk
ad_connect sys_cpu_clk eth_mcdma/m_axi_sg_aclk
ad_connect xxv_eth/tx_clk_out_0 eth_tx_fifo/s_axis_aclk
ad_connect xxv_eth/tx_clk_out_0 eth_mcdma/m_axi_mm2s_aclk
ad_connect xxv_eth/rx_clk_out_0 xxv_eth/rx_core_clk_0
ad_connect xxv_eth/rx_clk_out_0 eth_rx_fifo/s_axis_aclk
ad_connect xxv_eth/rx_clk_out_0 eth_mcdma/m_axi_s2mm_aclk

# resets
ad_connect sys_cpu_resetn xxv_eth/s_axi_aresetn_0
ad_connect sys_cpu_resetn eth_mcdma/axi_resetn
ad_connect sys_rstgen/peripheral_reset xxv_eth/sys_reset
ad_connect sys_ps8/pl_resetn0 gt_datapath_rst/Op1
ad_connect gt_datapath_rst/Res xxv_eth/gtwiz_reset_tx_datapath_0
ad_connect gt_datapath_rst/Res xxv_eth/gtwiz_reset_rx_datapath_0
ad_connect eth_mcdma/mm2s_prmry_reset_out_n dma_tx_rst/Op1
ad_connect dma_tx_rst/Res xxv_eth/tx_reset_0
ad_connect eth_mcdma/s2mm_prmry_reset_out_n dma_rx_rst/Op1
ad_connect dma_rx_rst/Res xxv_eth/rx_reset_0
ad_connect xxv_eth/user_tx_reset_0 tx_rst_n/Op1
ad_connect tx_rst_n/Res eth_tx_fifo/s_axis_aresetn
ad_connect xxv_eth/user_rx_reset_0 rx_rst_n/Op1
ad_connect rx_rst_n/Res eth_rx_fifo/s_axis_aresetn

# control tie-offs
ad_connect outclksel_const/dout xxv_eth/txoutclksel_in_0
ad_connect outclksel_const/dout xxv_eth/rxoutclksel_in_0
ad_connect preamble_const/dout xxv_eth/tx_preamblein_0
ad_connect xxv_eth/ctl_tx_send_idle_0 GND
ad_connect xxv_eth/ctl_tx_send_lfi_0 GND
ad_connect xxv_eth/ctl_tx_send_rfi_0 GND
ad_connect xxv_eth/qpllreset_in_0 GND

# datapath
ad_connect eth_mcdma/M_AXIS_MM2S eth_tx_fifo/S_AXIS
ad_connect eth_tx_fifo/M_AXIS xxv_eth/axis_tx_0
ad_connect xxv_eth/axis_rx_0 eth_rx_fifo/S_AXIS
ad_connect eth_rx_fifo/M_AXIS eth_mcdma/S_AXIS_S2MM

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

# register maps + coherent DMA memory path (HPC0) + per-channel interrupts.
# NOTE: xxv_eth/s_axi_0 is deliberately NOT assigned -- the open_mac_splice
# reconfigures xxv_eth to PCS/PMA-only (s_axi_0 disappears) and assigns the
# xxv_shim register block at 0x80060000 in its place (via ad_cpu_interconnect).
ad_cpu_interconnect 0x80020000 eth_mcdma S_AXI_LITE
ad_mem_hpc0_interconnect sys_cpu_clk sys_ps8/S_AXI_HPC0_FPD
ad_mem_hpc0_interconnect sys_cpu_clk eth_mcdma/M_AXI_SG
ad_mem_hpc0_interconnect xxv_eth/tx_clk_out_0 eth_mcdma/M_AXI_MM2S
ad_mem_hpc0_interconnect xxv_eth/rx_clk_out_0 eth_mcdma/M_AXI_S2MM
ad_cpu_interrupt ps-10 mb-10 eth_mcdma/mm2s_ch1_introut
ad_cpu_interrupt ps-11 mb-11 eth_mcdma/s2mm_ch1_introut

###############################################################################
# License-free 10G + TX checksum offload (v0.67 reuse). Applied as post-BD
# splices onto the licensed-MAC 10G block above:
#   1. tx_csum_splice.tcl : insert tx_csum_open straddling eth_tx_fifo (must run
#      FIRST, while xxv_eth is still in MAC mode using axis_tx_0).
#   2. open_mac_splice.tcl : reconfigure xxv_eth -> free "PCS/PMA 64-bit" core
#      (no license, no eval timebomb) + open_mac_10g + xxv_shim@0x80060000 so the
#      stock xilinx_axienet driver + DT (xlnx,txcsum=1) run UNCHANGED.
# Custom IPs come from cso_open/iprepo (added to ip_repo_paths above).
###############################################################################
source tx_csum_splice.tcl
source open_mac_splice.tcl
