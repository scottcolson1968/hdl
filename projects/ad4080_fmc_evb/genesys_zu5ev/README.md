# Wildcat2 — EVAL-AD4080-FMC on Digilent Genesys ZU-5EV

Port of the [ad4080_fmc_evb](https://analogdevicesinc.github.io/hdl/projects/ad4080_fmc_evb/index.html)
project from the ZedBoard to the Digilent Genesys ZU-5EV (Zynq UltraScale+
XCZU5EV-SFVC784-1-E, FMC LPC connector). Not an officially supported ADI carrier.

This is the FPGA side of **Wildcat2**, the successor to the AD7383-4 "Wildcat"
system. It reuses that project's carrier bring-up and backhaul wholesale and
swaps in the AD4080 front-end. Versioning restarts at **v1.0.0** (see
`VERSION.txt`).

## ADC
AD4080 — 20-bit, 40 MSPS differential SAR ADC with an **LVDS** output interface
(DCO source-synchronous clock + DA/DB data lanes, CNV input, `filter_data_ready`).
This is a fundamentally different front-end from the AD7383-4's SPI-Engine
capture, so the capture datapath (`axi_ad408x` + `axi_clock_monitor` + `axi_dmac`)
and its FMC pin mapping are new work; almost everything else is inherited.

## What is reused from Wildcat (ad738x_fmc/genesys_zu5ev)
- **Carrier**: `common/genesys-zu5ev/genesys_zu5ev_system_bd.tcl` — `sys_ps8`,
  30 MHz `PS_REF_CLK`, EMIO SPI0/SPI1, 95-bit EMIO GPIO, sysid, clocks.
- **VADJ manual-override arm** — the rising-edge `vadj_auton` sequencer in
  `system_top.v` (the MCU refuses autonomous VADJ for these eval cards).
- **10G SFP+ backhaul** — `xxv_ethernet` (MAC+PCS/PMA 64-bit BASE-R) + `axi_mcdma`,
  GTH Quad_X0Y1 / lane X0Y7, plus the open-MAC + TX-checksum-offload splice
  (`open_mac_splice.tcl`, `tx_csum_splice.tcl`) applied post-build.
- **RGB status LED** — `rgb_led_gpio.tcl` + LD5 constraints (red=boot, blue=iiod
  starting, green=safe to connect).
- **Root filesystem / services** (on the board, not in this tree): iiod-0.26
  service, WiFi AP (MT7921U), USB-stick auto-updater, `fw_version`/`VERSION.txt`
  context attr, fast headless boot.

## What is new for AD4080
- `system_bd.tcl` §1 — AD4080 LVDS capture (adapted from
  `../common/ad4080_fmc_evb_bd.tcl`, which hard-codes `sys_ps7`/`S_AXI_HP1`; here
  it is inlined against `sys_ps8` with the ADC DMA on **HP0** and 10G on HPC0).
- `system_top.v` — AD4080 LVDS ports, AD4080 control SPI on **PS SPI0**, AD9508 +
  ADF4350 clock SPI on **PS SPI1**, and the eval-board power/enable straps.
- Linux: the **`ad4080` IIO driver** replaces `ad7380`; new device tree.

## Prerequisites
- Vivado 2025.1 (matches the `hdl_2026_r1` branch this port is built on)
- Digilent board files (`digilentinc.com:gzu_5ev`); `system_project.tcl` points
  `board.repoPaths` at `D:/digilent-vivado-boards/new/board_files` — override
  with the `GENESYS_ZU_BOARD_FILES` environment variable if located elsewhere.

## Building (WSL — primary flow)
```bash
source /opt/Xilinx/2025.1/Vivado/settings64.sh
cd /mnt/d/hdl/projects/ad4080_fmc_evb/genesys_zu5ev
make    # ADC_N_BITS=20 default
```
Result: `ad4080_fmc_evb_genesys_zu5ev.xpr` in this directory.

## Open work (must be done before a hardware build)
0. **VADJ 1.8 V — RESOLVED (confirmed safe).** Per the RevF schematic + AD4080
   datasheet: `FMC_VADJ` powers only the `SN74AVC1T45` level translators
   (`VCCA` 1.65–5.5 V), so 1.8 V is in spec. The ADC IO rail (1.1 V) is on-board
   regulated from 3.3 V, and the AD9508/ADF4350 clocks run on +3V3CLK — nothing
   needs 2.5 V. The eval's "2.5 V" is just a default. Part B (1.8 V) is correct.
1. **FMC pin mapping (Part B of `system_constr.xdc`)** — ✅ DONE. Every AD4080
   LVDS / SPI / GPIO port assigned by cross-referencing the ADI zed FMC-net
   table with the Digilent master (net → ZU pin), translated to 1.8 V HP-bank
   IOSTANDARDs. DCO / ref / 100 MHz clocks verified on clock-capable pins.
   `cnv_in_p/n` needs no pin — it is a dangling `axi_ad408x` port (unused; the
   eval aliases it to FPGACLK/CLK1_M2C), so the dead ports were removed and the
   IP inputs tied to GND.
2. **EMIO GPIO ↔ device-tree alignment** — the eval-board control block
   (`gpio_o[50:44]` region in `system_top.v`) line numbers must match the
   Wildcat2 device tree (spi cs, clock driver, gpio-hogs).
3. **AD4080 sample-clock / DCO timing** — the `create_clock` periods are carried
   from the ADI zed reference (DCO 400 MHz); re-verify against the actual
   AD9508/ADF4350 sample-clock plan and add IODELAY on the LVDS data lanes.
4. **Linux**: bring up the `ad4080` IIO driver + DT on the Wildcat2 rootfs.
