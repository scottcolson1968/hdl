###############################################################################
## Copyright (C) 2024-2025 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
##
## Wildcat2 : EVAL-AD4080-FMC on Genesys ZU-5EV FMC LPC connector.
##
## Part A -- backhaul (10G SFP+, RGB LED), reused verbatim from the Wildcat
##           ad738x port. Board-fixed, verified.
## Part B -- AD4080 FMC front-end. Pins derived by cross-referencing the ADI
##           ad4080_fmc_evb/zed FMC-net assignment against the Digilent
##           Genesys-ZU-5EV-D-Master.xdc FMC LA/CLK net -> package-pin table.
##
## VADJ = 1.8 V: CONFIRMED SAFE (RevF schematic + AD4080 datasheet, 2026-07-24).
##   The eval's "VADJ = 2.5 V" is only a default, NOT a requirement. FMC_VADJ on
##   the board powers ONLY the SN74AVC1T45 level translators (VCCA = 1.65-5.5 V),
##   so 1.8 V is in spec. The ADC IO rail (VDDIO11/IOVDD = 1.1 V) is regulated
##   on-board from VDD33 (3.3 V); the AD9508 fanout + ADF4350 PLL run on +3V3CLK.
##   Nothing on the board needs 2.5 V. All Part-B IOSTANDARDs below use VADJ =
##   1.8 V (LVDS / LVCMOS18), which the Genesys ZU HP banks 64/65 (VCCO <= 1.8 V)
##   supply natively.
###############################################################################

###############################################################################
## PART A -- backhaul (verified, reused from Wildcat)
###############################################################################

## 10G SFP+ (GTH bank 224 ch3). Lane/refclk LOCs set by the xxv_ethernet IP.
set_property PACKAGE_PIN Y6 [get_ports gt_refclk_p]
set_property PACKAGE_PIN Y5 [get_ports gt_refclk_n]
create_clock -period 6.400 -name gt_refclk [get_ports gt_refclk_p]

set_property -dict {PACKAGE_PIN AD14 IOSTANDARD LVCMOS33} [get_ports sfp_mod_detect]
set_property -dict {PACKAGE_PIN W13  IOSTANDARD LVCMOS33} [get_ports sfp_rs0]
set_property -dict {PACKAGE_PIN Y14  IOSTANDARD LVCMOS33} [get_ports sfp_rs1]
set_property -dict {PACKAGE_PIN W14  IOSTANDARD LVCMOS33} [get_ports sfp_rx_los]
set_property -dict {PACKAGE_PIN AB13 IOSTANDARD LVCMOS33} [get_ports sfp_tx_disable]
set_property -dict {PACKAGE_PIN AA13 IOSTANDARD LVCMOS33} [get_ports sfp_tx_fault]
set_property -dict {PACKAGE_PIN D10  IOSTANDARD LVCMOS18} [get_ports sel_sfp_not_fmc]

## RGB status LED LD5 (bank 66, LVCMOS12) <- PS EMIO GPIO o[46:44].
set_property -dict {PACKAGE_PIN C9 IOSTANDARD LVCMOS12} [get_ports ld5_r]
set_property -dict {PACKAGE_PIN B9 IOSTANDARD LVCMOS12} [get_ports ld5_g]
set_property -dict {PACKAGE_PIN A8 IOSTANDARD LVCMOS12} [get_ports ld5_b]

###############################################################################
## PART B -- AD4080 FMC front-end (VADJ = 1.8 V; HP banks 64/65)
##
##  Each line:  ZU pkg pin  IOSTANDARD  [port]   ## <FMC net> (ADI zed pin)
##  Translation source: ADI ad4080_fmc_evb/zed/system_constr.xdc (FMC net) +
##  Genesys-ZU-5EV-D-Master.xdc (net -> ZU pin). LVDS_25->LVDS, LVCMOS25->LVCMOS18.
###############################################################################

## --- LVDS data + clocks (differential, on-die 100 ohm termination) ---
## DCO is the source-synchronous data clock -> lands on a clock-capable (GC) pin.
set_property -dict {PACKAGE_PIN M6  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports dco_p]   ;## FMC_CLK0_M2C_P (GC_65)  zed dco_p
set_property -dict {              IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports dco_n]   ;## FMC_CLK0_M2C_N (Vivado places complement)

set_property -dict {PACKAGE_PIN J6  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports da_p]    ;## FMC_LA02_P (65)  zed da_p
set_property -dict {PACKAGE_PIN H6  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports da_n]    ;## FMC_LA02_N (65)  zed da_n

set_property -dict {PACKAGE_PIN K4  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports db_p]    ;## FMC_LA03_P (65)  zed db_p
set_property -dict {PACKAGE_PIN K3  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports db_n]    ;## FMC_LA03_N (65)  zed db_n

## 100 MHz reference (fpga_100_clk) -> CLK1_M2C (GC)
set_property -dict {PACKAGE_PIN L3  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports fpgaclk_p] ;## FMC_CLK1_M2C_P (GC_65)
set_property -dict {              IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports fpgaclk_n] ;## FMC_CLK1_M2C_N (complement)

## reference clock (fpga_ref_clk) -> LA01_CC (clock-capable QBC)
set_property -dict {PACKAGE_PIN H4  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports clk_p]   ;## FMC_LA01_CC_P (QBC_65)  zed clk_p
set_property -dict {PACKAGE_PIN H3  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports clk_n]   ;## FMC_LA01_CC_N (QBC_65)  zed clk_n

## --- AD4080 control SPI (PS SPI0) ---
set_property -dict {PACKAGE_PIN R7  IOSTANDARD LVCMOS18} [get_ports ad4080_csn]   ;## FMC_LA08_P (65)  zed G12
set_property -dict {PACKAGE_PIN J9  IOSTANDARD LVCMOS18} [get_ports ad4080_sclk]  ;## FMC_LA07_N (65)  zed H14
set_property -dict {PACKAGE_PIN T7  IOSTANDARD LVCMOS18} [get_ports ad4080_mosi]  ;## FMC_LA08_N (65)  zed G13
set_property -dict {PACKAGE_PIN K9  IOSTANDARD LVCMOS18} [get_ports ad4080_miso]  ;## FMC_LA07_P (65)  zed H13

## --- Clock-generator SPI (AD9508 + ADF4350, PS SPI1) ---
set_property -dict {PACKAGE_PIN P6  IOSTANDARD LVCMOS18} [get_ports ad9508_csn]           ;## FMC_LA14_N (65)  zed C19
set_property -dict {PACKAGE_PIN AG9 IOSTANDARD LVCMOS18} [get_ports adf4350_csn]          ;## FMC_LA18_CC_P (64)  zed C22
set_property -dict {PACKAGE_PIN N6  IOSTANDARD LVCMOS18} [get_ports ad9508_adf4350_sclk]  ;## FMC_LA13_N (65)  zed D18
set_property -dict {PACKAGE_PIN N7  IOSTANDARD LVCMOS18} [get_ports ad9508_adf4350_miso]  ;## FMC_LA13_P (65)  zed D17
set_property -dict {PACKAGE_PIN P7  IOSTANDARD LVCMOS18} [get_ports ad9508_adf4350_mosi]  ;## FMC_LA14_P (65)  zed C18

## --- eval-board power / clock enable / status straps ---
set_property -dict {PACKAGE_PIN R8  IOSTANDARD LVCMOS18} [get_ports en_psu]       ;## FMC_LA15_P (65)  zed H19
set_property -dict {PACKAGE_PIN T8  IOSTANDARD LVCMOS18} [get_ports pwrgd]        ;## FMC_LA15_N (65)  zed H20
set_property -dict {PACKAGE_PIN AC4 IOSTANDARD LVCMOS18} [get_ports pd_v33b]      ;## FMC_LA19_P (64)  zed H22
set_property -dict {PACKAGE_PIN H7  IOSTANDARD LVCMOS18} [get_ports osc_en]       ;## FMC_LA12_N (65)  zed G16
set_property -dict {PACKAGE_PIN L1  IOSTANDARD LVCMOS18} [get_ports ad9508_sync]  ;## FMC_LA06_P (65)  zed C10
set_property -dict {PACKAGE_PIN AH9 IOSTANDARD LVCMOS18} [get_ports adf435x_lock] ;## FMC_LA18_CC_N (64)  zed C23

## --- eval-board GPIO / direction ---
set_property -dict {PACKAGE_PIN K1  IOSTANDARD LVCMOS18} [get_ports gpio1_fmc]    ;## FMC_LA06_N (65)  zed C11  -> filter_data_ready_n
set_property -dict {PACKAGE_PIN M8  IOSTANDARD LVCMOS18} [get_ports gpio2_fmc]    ;## FMC_LA09_P (65)  zed D14
set_property -dict {PACKAGE_PIN L8  IOSTANDARD LVCMOS18} [get_ports gpio3_fmc]    ;## FMC_LA09_N (65)  zed D15
set_property -dict {PACKAGE_PIN J5  IOSTANDARD LVCMOS18} [get_ports gp0_dir]      ;## FMC_LA11_P (65)  zed H16
set_property -dict {PACKAGE_PIN H1  IOSTANDARD LVCMOS18} [get_ports gp1_dir]      ;## FMC_LA10_N (65)  zed C15
set_property -dict {PACKAGE_PIN J7  IOSTANDARD LVCMOS18} [get_ports gp2_dir]      ;## FMC_LA12_P (65)  zed G15
set_property -dict {PACKAGE_PIN J4  IOSTANDARD LVCMOS18} [get_ports gp3_dir]      ;## FMC_LA11_N (65)  zed H17

## --- clocks ---
## THESE PERIODS ARE INHERITED FROM THE ADI ZED REFERENCE AND ARE KNOWN NOT TO
## MATCH THE WILDCAT2 CLOCK PLAN. They are left unchanged ON PURPOSE for the
## 2026-08-03 diagnostic build; do not "fix" them from a calculation alone.
##
##   dco_clk  2.500 ns => 400 MHz. Expected real DCO is ~163.84 MHz:
##            32.768 MSPS x 20 bits / 2 lanes / 2 (DDR) = 5 DCO periods/sample.
##            Left OVER-constrained deliberately - over-constraining is
##            timing-SAFE, whereas relaxing it to a guessed-low value would let
##            timing close falsely and could break capture. The clock monitor
##            now measures adc_clk (= DCO/2) at 0x80050048, so the next build
##            can set this from a MEASUREMENT rather than arithmetic.
##
##   fpga_clk 10.00 ns => 100 MHz, but fpgaclk_p is FMC_CLK1_M2C = AD9508 ch0
##            "FPGACLK", confirmed running at 327.68 MHz (divider 1) via
##            clk_summary and the AD9508 registers. Correcting this TIGHTENS a
##            327 MHz constraint onto the diagnostic clock-monitor counter path
##            and risks failing timing on a build whose only job is to measure
##            DCO. Fix it together with dco_clk in the follow-up build.
##
##   ref_clk  2.500 ns on clk_p (LA01_CC). What the eval card actually drives on
##            LA01_CC is not documented in common/ad4080_fmc_evb.txt - determine
##            before trusting this one.
create_clock -period 2.500 -name dco_clk  [get_ports dco_p]     ;## see note above
create_clock -period 2.500 -name ref_clk  [get_ports clk_p]
create_clock -period 10.00 -name fpga_clk [get_ports fpgaclk_p] ;## see note above

## The reference/monitor clocks (clk_p = LA01_CC, fpgaclk_p = CLK1_M2C) feed the
## DIAGNOSTIC axi_clock_monitor through a BUFGCE_DIV. The placer cannot put the
## FMC GCIO and that BUFG in the same clock region (Place 30-675). These are not
## datapath clocks (the capture clock is DCO, which places on dedicated routing),
## so demote the dedicated-route rule -- the standard override for FMC
## clock-capable inputs driving fabric logic.
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets i_fpga_clk/O]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets i_fpga_100_clk/O]

###############################################################################
## RESOLVED: cnv_in_p/n needs NO pin. On the eval it is merely an alias of
## FPGACLK (FMC_CLK1_M2C, monitored as fpga_100_clk below), and axi_ad408x
## does not use the signal (cnv_in is a dangling IP port -- framing is rebuilt
## from sync_n + DCO + filter_data_ready). The dead ports were removed from
## system_bd.tcl / system_top.v; the IP inputs are tied to GND.
##
## STILL OPEN (do not treat this file as final):
##  * VADJ 1.8 V vs eval's 2.5 V -- see the blocker banner at the top.
##  * doa/dob/doc/dod_fmc (zed LA24/LA16 digital outputs) are not brought out in
##    this port; add them if the bring-up needs them.
###############################################################################
