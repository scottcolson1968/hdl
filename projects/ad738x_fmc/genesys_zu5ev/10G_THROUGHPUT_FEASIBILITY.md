# 10 GbE Throughput Feasibility — Genesys ZU‑5EV DAQ

**Subject:** Why sustained ~10 Gbps data throughput is not achievable with the current
DAQ architecture, and what the realistic ceiling is.

**Audience:** Engineering + program stakeholders evaluating the 10 GbE effort.

---

## 1. Executive summary

The board has a working 10 GbE (SFP+) link, and it is the right choice for this product.
However, **the 10 Gbps figure refers to the wire, not to achievable application
throughput.** Measured, sustained data throughput over that link tops out at
**~1.7–1.9 Gbps (≈ 200–230 MiB/s) — roughly 17–20 % of the 10 G wire.**

This is **not** a tuning problem and cannot be closed by configuration. Three independent,
measured facts establish the ceiling:

1. **The bottleneck is the Zynq processing system (PS), not the link.** Raw TCP
   (`iperf3`, no DAQ software involved) maxes out at **1.94 Gbps** on this SoC — and
   does **not** improve with parallel streams or jumbo frames. The 10 G wire sits
   ~80 % idle.
2. **The IIO software stack is TCP‑only.** The one protocol that could push meaningfully
   higher — UDP — is **not supported by libiio**. Using it means abandoning the entire
   IIO / IIO‑Oscilloscope / Scopy software ecosystem.
3. **The instrument does not produce 10 Gbps of data.** The ADC's full output is
   **~2.17 Gbps** (16 ch × 4 B × ~4.1–4.24 MSPS). There is no 10 Gbps workload to carry;
   10 G is ~5× the maximum data the instrument generates.

**Bottom line:** ~2 Gbps is the practical ceiling of any TCP/libiio path on this
hardware. Reaching 10 Gbps would require replacing the software transport architecture
(custom UDP or an FPGA‑direct streaming engine), not faster networking — and is not
warranted by a ~2.2 Gbps data source.

---

## 2. Measured throughput (this hardware)

| Path | Throughput | vs 10 G wire |
|------|-----------:|-------------:|
| 10 GbE wire (theoretical, after framing) | ~9.4 Gbps (~1120 MiB/s) | 100 % |
| **ADC data production (the actual workload)** | **~2.17 Gbps (~259 MiB/s)** | ~23 % |
| Raw TCP, `iperf3` board→PC (no DAQ sw) | **~1.94 Gbps (~231 MiB/s)** | ~20 % |
| IIO streaming over 10 G (`iiod`/libiio) | **~1.68 Gbps (~200 MiB/s)** | ~17 % |
| (reference) On‑board local capture, no network | ~2.17 Gbps (~259 MiB/s) | — |
| (reference) `iiod` over loopback (no physical NIC) | ~2.16 Gbps (~258 MiB/s) | — |

*Test setup: Genesys ZU‑5EV, SFP+ (`sfp0`) ↔ Intel X550 NIC, MTU 9000 (jumbo enabled),
16‑channel ad7383‑4 capture, libiio 0.26 `iiod`. iperf3 figure unchanged with `-P4`.*

Reading the table:
- The **wire** has ~5× headroom over anything we can feed it.
- **Raw TCP (1.94 Gbps)** is the hard SoC ceiling — measured with a pure network
  benchmark, no DAQ code in the path.
- **IIO streaming (1.68 Gbps)** sits just under that: `iiod` adds per‑sample
  copy/serialization on top of TCP.
- **Loopback ≈ local ≈ 2.1 Gbps** proves the board *can* move ~2.2 Gbps internally; it's
  the **physical TCP transmit path on the A53 cores** that drops it to ~1.7–1.9 Gbps.

---

## 3. Why the ceiling exists (root cause)

The data path is: **ADC → FPGA DMA → Linux on the Zynq A53 cores → `iiod` → TCP/IP →
10 G MAC → wire.**

Everything from "Linux on the A53" onward runs in software on the Zynq UltraScale+ **PS**
(four Arm Cortex‑A53 cores). For every byte sent, those cores must copy the data and run
the Linux TCP/IP stack (segmentation, checksums, ACK processing, congestion control).
**That per‑byte CPU cost is the wall.**

Evidence it is the PS, not the link or TCP tuning:
- `iperf3` (pure TCP) caps at **1.94 Gbps and does not rise with 4 parallel streams** →
  not a single‑stream/window limit; it's aggregate CPU/MAC.
- **Jumbo frames (MTU 9000) are already enabled** and do not lift it.
- During streaming the link utilization is ~17–20 %; the cores are the constraint, not
  bandwidth.

This is inherent to running a general‑purpose software TCP stack on an embedded Arm PS.
A faster wire (the 10 G) cannot help when the limit is upstream in the CPU.

---

## 4. Why UDP is the only protocol lever — and why it's unavailable

TCP spends significant CPU per byte on reliability machinery (ACKs, retransmit state,
congestion control). **UDP** drops most of that, so a UDP streamer *could* push closer to
the MAC/memory limit (plausibly a few Gbps, still not 10). UDP is lossy, so the
application would have to tolerate or re‑implement dropped‑packet handling — acceptable
for some streaming use cases.

**However: libiio's network backend is TCP‑only.** The IIOD protocol runs exclusively
over TCP (port 30431); there is no UDP option in the library. Therefore:

- Using UDP means **writing a custom streaming protocol on both the board and every
  client** — and **abandoning libiio, IIO‑Oscilloscope, Scopy, and the gr‑iio /
  application ecosystem** that depend on the IIO interface.
- Even then, UDP on the A53 would not reach 10 Gbps — it would raise the ceiling, not
  remove it (the PS memory/MAC bandwidth becomes the next wall).

So the one knob that could materially help is both **outside libiio's capability** and
**insufficient on its own** to reach 10 G.

---

## 5. Is 10 Gbps even a meaningful target?

No — not for this instrument's data rate. The ADC produces **~2.17 Gbps** at full rate.
A transport target above the data source is not physically meaningful: there is nothing
to put on the wire above ~2.2 Gbps.

What this means in practice:
- **10 G is still the right link** — because it can carry **most of the ~2.2 Gbps ADC
  rate**, which a 1 GbE link physically cannot (1 GbE caps at ~0.94 Gbps ≈ 43 % of the
  data). 10 G delivers ~1.7–1.9 Gbps (~77–89 % of full rate); 1 G delivers <½.
- So the 10 G effort **already pays off** by enabling near‑full‑rate capture — it just
  cannot, and need not, be "saturated."

---

## 6. What it would actually take to approach 10 Gbps (and feasibility)

| Approach | Could it approach 10 G? | Feasibility / cost |
|----------|------------------------|--------------------|
| TCP tuning (windows, parallel streams, jumbo) | No — already at the ~1.94 Gbps SoC ceiling | Done; no further gain |
| libiio 1.x zero‑copy / dmabuf | No — removes a copy but TCP on A53 still caps ~1.9 Gbps | Tested; did not beat the ceiling |
| Custom **UDP** streamer | Partially (a few Gbps, lossy) | High effort; **abandons libiio ecosystem**; app must handle loss |
| Kernel‑bypass (DPDK / AF_XDP / RDMA) | Unlikely on Zynq A53 + this MAC | Not practical on this platform |
| **FPGA‑direct streaming** (TCP/UDP engine in PL, DMA ADC→MAC, bypass the PS) | Yes, in principle | Major FPGA development; **changes the product architecture**; abandons the Linux/libiio model |

The only path that can genuinely approach 10 G is **#FPGA‑direct streaming** — moving the
network stack into the programmable logic so the A53 cores are out of the data path. That
is a substantial hardware development effort and a different product architecture, and it
would still be solving for a 10 G wire that the ~2.2 Gbps instrument cannot fill.

---

## 7. Recommendation

1. **Keep the 10 GbE link** — it is justified: it carries ~77–89 % of the full ADC rate,
   which 1 GbE cannot.
2. **Set the throughput expectation at ~1.7–1.9 Gbps (~200–230 MiB/s)** for any
   TCP/libiio path on this SoC, and document it as an architectural property of the
   Zynq PS, not a defect or a tuning gap.
3. **Do not target "10 Gbps saturation"** — it is infeasible with the current
   (ADC → A53 → libiio/TCP) architecture and unnecessary for a ~2.2 Gbps data source.
4. **If a future requirement genuinely exceeds ~2 Gbps**, the only viable route is an
   FPGA‑direct streaming engine (PL‑resident UDP/TCP, PS bypass) — scope it as a hardware
   project, with the understanding that it abandons the libiio software model.

---

*Prepared from on‑hardware measurements (Genesys ZU‑5EV, 16‑channel ad7383‑4): `iperf3`
raw‑TCP benchmark, `iio_readdev -B` over 10 G / loopback / local, libiio 0.26.*
