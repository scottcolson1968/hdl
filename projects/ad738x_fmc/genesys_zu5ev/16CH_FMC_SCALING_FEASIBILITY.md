# 16‑Channel Scaling Feasibility — Genesys ZU‑5EV / ad7383‑4 DAQ

**Subject:** Feasibility of expanding the DAQ from one ad7383‑4 (4 channels) to four
ad7383‑4 devices (**16 simultaneous real channels**) on a custom FMC mezzanine, with
focus on FMC connector capacity and data bandwidth.

**Audience:** Engineering + program stakeholders evaluating a custom 16‑channel board.

**Date:** 2026‑06‑30

---

## 1. Executive summary

Expanding to 16 simultaneous channels (4 × ad7383‑4) through the FMC connector is
**feasible**. The two questions usually asked first — *"are there enough FMC pins?"* and
*"can the link carry the extra data?"* — both clear with large margin:

- **FMC pins: not a constraint.** The current design uses **7 of 68** available
  single‑ended FMC pins. A full 16‑channel design needs **19** — leaving **~49 pins
  (~72 %) free**.
- **Data bandwidth: already proven.** The system **already moves 16 channels' worth of
  data today** (4 real + 12 duplicated copies). Replacing the copies with real channels is
  the **identical wire load** (~250 MB/s) — a rate the hardware already sustains.

The genuine engineering work is **not** in the connector or the data rate. The single
largest hardware risk — powering four ADCs plus a 16‑channel analog front‑end from the
carrier's limited FMC rails — is **resolved by powering the mezzanine externally**
(recommended). With that decision made, the remaining work is **(a) 80 MHz signal
integrity for 16 data lanes** and **(b) FPGA/driver rework** to read four real chips
instead of replicating one.

---

## 2. FMC connector capacity

The Genesys ZU‑5EV carries a **full FMC LPC** connector: all **34 LA pairs (LA00–LA33)
are routed = 68 single‑ended user I/O**, plus two dedicated differential clock inputs
(CLK0/1_M2C). (There are no HA/HB banks — those are HPC‑only.)

### Current usage — 7 of 68 pins (~10 %)

| Signal | FMC pin | Role |
|--------|---------|------|
| spi_sclk | LA00_CC_P | SPI clock — **shared** |
| spi_cs   | LA00_CC_N | chip‑select / convert trigger — **shared** |
| spi_sdo  | LA02_P    | config (MOSI) to ADC — **shared** |
| spi_sdia | LA01_CC_P | data lane 0 |
| spi_sdib | LA01_CC_N | data lane 1 |
| spi_sdic | LA02_N    | data lane 2 |
| spi_sdid | LA03_P    | data lane 3 |

One ad7383‑4 = **3 shared control lines + 4 data (SDI) lines = 7 pins.**

### Projected usage for 16 channels (4 × ad7383‑4) — 19 pins

The three control lines **remain shared** across all four chips: a single SCLK, a single
CS (which also triggers the simultaneous conversion on every chip at once), and a single
broadcast configuration line. **Only the data lanes multiply.**

| Group | Pins | Notes |
|-------|-----:|-------|
| Shared control (SCLK, CS, SDO) | 3 | unchanged — broadcast to all 4 chips |
| Data — SDI | 16 | 4 lanes/chip × 4 chips |
| **Total** | **19** | **+12 over the current design** |

### Budget summary

| | Pins |
|---|---:|
| FMC single‑ended user I/O available (LPC, 34 LA pairs) | **68** |
| Used today (1 chip) | 7 |
| Required for 16 channels (4 chips) | 19 |
| **Free after 16‑channel build** | **~49 (~72 %)** |

Two dedicated differential clock inputs (CLK0/1_M2C) also remain available. **There is
enough pin headroom for a fifth chip and still margin to spare** — the FMC connector is
not a limiting factor for this expansion.

---

## 3. Data bandwidth

**The expansion adds no new bandwidth burden** because the present system already moves a
full 16‑channel payload.

The current single‑chip design pads its 4 real channels up to a 16‑channel frame by
**duplicating** each channel ×4 (channels 4–15 are copies of 0–3). On the wire this is
already **64 bytes/scan × 4.096 MSPS ≈ 250 MB/s (≈ 240 MiB/s)**. Replacing the 12 copies
with 12 *real* channels produces the **exact same frame size and the exact same data
rate** — only now every channel is unique.

| Configuration | Real ch | Wire payload | Data rate |
|---|---:|---:|---:|
| Today (1 chip, 12 copies) | 4 | 64 B/scan | ~250 MB/s (~240 MiB/s) |
| Proposed (4 chips, no copies) | 16 | 64 B/scan | ~250 MB/s (~240 MiB/s) |

Because the rate is unchanged, the **already‑measured** transport behavior applies
directly:

- **On‑board / local capture: ~259 MiB/s** — keeps up with all 16 channels at full
  4.096 MSPS.
- **USB3 or 10 GbE: ~200 MiB/s** — the Zynq PS (A53) transport ceiling. As today, a
  *fully lossless* 16‑channel stream at the full rate slightly exceeds this; sustained
  network/USB capture runs at ~200 MiB/s. (See the companion *10 GbE Throughput
  Feasibility* memo — this ceiling is a property of the SoC software transport, not of
  the channel count, and does not change with more real channels.)

### SPI timing also unchanged

Each ad7383‑4 already outputs its four channels **in parallel** on four SDI lanes; a
16‑bit conversion is 16 SCLK cycles regardless. Four chips give 16 SDI lanes read by a
wider engine in the **same 16 SCLK cycles (~200 ns at 80 MHz)**. Sixteen real channels at
4.096 MSPS therefore costs the **same SPI time budget** as today's four — more lanes,
not more time.

---

## 4. The real engineering considerations

These — not pins or data rate — are where the effort and risk live.

### 4.1 Mezzanine power — power the board externally *(recommended)*
The FMC VADJ/3.3 V/12 V rails have a limited current budget on this carrier — we already
reached it with a **single** eval card (it required an EEPROM patch down to ~2 A). Four
ADCs plus a 16‑channel analog front‑end (input buffers, references, regulators) would not
reliably fit that budget if drawn from the carrier.

**The recommended approach is to power the custom mezzanine from an external supply.**
This moves the heavy analog/ADC current off the carrier entirely and **removes the FMC
power budget as a constraint.** It does, however, introduce three smaller, well‑understood
design items that must be handled:

1. **VADJ must still be set to the I/O voltage (1.8 V), at near‑zero current.** The FMC LA
   pins are LVCMOS18; the carrier FPGA bank (bank 65) VCCO and the mezzanine's digital I/O
   drivers must agree at 1.8 V. With external power, VADJ sources only I/O‑buffer leakage,
   so the budget is trivially met — **program the mezzanine's FRU EEPROM to request
   VADJ = 1.8 V at low current**, which also cleanly avoids the over‑budget fault seen on
   the eval card.
2. **Common ground is mandatory.** The external supply ground must bond to the FMC ground
   pins — that is the signal return for 16 SDI + SCLK at 80 MHz. (The FMC has ample GND
   pins.)
3. **Power sequencing / back‑powering.** Ensure the externally powered mezzanine does not
   drive the FPGA pins (through I/O clamp diodes) before the FPGA bank VCCO is up, or vice
   versa. Sequence the external supply with the carrier, or gate the mezzanine I/O on a
   power‑good signal.

If instead the board were powered from the carrier, the VADJ/3.3 V/12 V current budget
would need to be sized first and would be the most probable hard constraint — which is why
external power is recommended.

### 4.2 Signal integrity — 16 lanes at 80 MHz
The data lanes are single‑ended LVCMOS18 today. Sixteen of them switching at 80 MHz across
the FMC require length‑matching and clean ground returns. Place SCLK on a clock‑capable
pair (LA00/01/17/18_CC) or a CLK_M2C input; consider an LVDS clock if margin is tight
(spare pairs are plentiful).

### 4.3 Clock / CS fanout on the mezzanine
One SCLK and one CS now drive four loads. Add a **fanout buffer on the custom board**
rather than daisy‑chaining four chips off a single FMC pin at 80 MHz.

### 4.4 FPGA datapath
Widen the SPI engine to **16 SDI** (or instantiate per‑chip engines), and **remove the
4→16 replication HLS**, replacing it with a real 16‑channel repack. The downstream
DMA / 512‑bit frame / transport is **unchanged** — it already carries 64 B/scan.

### 4.5 Driver / device tree
The `ad7380` Linux driver is per‑chip (one device = 4 channels). Supporting four real
chips means either (a) instantiating **four IIO devices** (four engines/offloads/DMA
streams), or (b) **modifying the driver** to present four chips as one 16‑channel device.
Today's "16 channels" is synthetic (copies); making it real requires one of these paths.

---

## 5. Conclusion & recommendation

| Question | Answer |
|---|---|
| Enough FMC pins? | **Yes** — 19 of 68 used, ~49 free (~72 % headroom). |
| Extra‑channel bandwidth do‑able? | **Yes** — identical to today's already‑sustained ~250 MB/s wire load. |
| SPI timing OK at 80 MHz? | **Yes** — parallel SDI keeps the read at ~200 ns / 16 SCLK. |
| Mezzanine power? | **Resolved by powering the board externally** (recommended); removes the FMC current‑budget constraint. |
| Where is the remaining work/risk? | **80 MHz signal integrity and FPGA/driver rework.** |

**Recommendation:** Proceed to a detailed design study. The FMC connector and the data
rate are **not** blockers and carry comfortable margin. **Power the custom mezzanine
externally** to take the carrier's FMC current budget off the table — then the design
reduces to three well‑bounded tasks: program the mezzanine FRU EEPROM for VADJ = 1.8 V
(low current) with proper ground bonding and power sequencing; lay out the 16 data lanes
for clean 80 MHz signal integrity (a standard mezzanine task, with ample spare pins to
support it); and implement the **FPGA datapath and driver changes** for four real chips.

---

*Prepared from the live v0.64 Genesys ZU‑5EV design constraints (FMC pin assignments,
master XDC LA‑pair count) and on‑hardware throughput measurements (local / USB3 / 10 GbE,
libiio 0.26).*
