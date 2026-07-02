# Connecting to the DAQ over 10 GbE (Windows client)

The DAQ serves IIO over its **10 GbE SFP+** link at **`10.2.2.2`** (MTU 9000, `iiod`
on TCP port **30431**). This guide sets up a fresh Windows PC to connect over that
link. It is a **direct, point‑to‑point** connection (board ↔ PC) — no switch and no
USB driver are required.

> For the USB‑C connection instead, see `WINDOWS_USB_DRIVER_INSTALL.md`.
> For why 10 G can't be "saturated," see `10G_THROUGHPUT_FEASIBILITY.md`.

| Board side (fixed) | Value |
|--------------------|-------|
| 10 G interface IP  | `10.2.2.2` / 24 |
| MTU (jumbo)        | `9000` |
| IIO daemon port    | `30431` (network) |

---

## 1. 10 GbE NIC + driver

1. Install a **10 GbE NIC** in the PC that matches the board's **SFP+** cage —
   a direct‑attach copper (DAC/twinax) cable or fiber + optics. A 10GBASE‑T NIC
   works only with a media converter. (Reference setup: **Intel X550**.)
2. Connect the **board SFP+ directly to the PC NIC** — no switch needed.
3. Install the **NIC vendor driver**. A clean Windows install often has no 10 G
   driver until you add it (vendor download or Windows Update). Confirm the adapter
   shows up under **Device Manager → Network adapters** with no warning.

## 2. Static IP on the 10 G adapter

A direct link has no DHCP, so assign a static address.

**Settings → Network & Internet → (the 10 G adapter) → Edit IP assignment → Manual → IPv4:**

| Field | Value |
|-------|-------|
| IP address | `10.2.2.10` (any `10.2.2.x` **except `.2`**) |
| Subnet mask / prefix | `255.255.255.0` (prefix `24`) |
| Gateway | *(leave blank)* |
| DNS | *(leave blank)* |

Then verify connectivity:
```
ping 10.2.2.2
```

## 3. Jumbo frames (for full throughput)

The board runs **MTU 9000**. Match it or throughput drops / packets fragment.

**Device Manager → the 10 G adapter → Properties → Advanced → Jumbo Packet → `9014 Bytes`**
(Intel's setting for a 9000‑byte MTU; other vendors may list `9000`/`9216`).

## 4. Firewall

`libiio` is **client‑initiated** (outbound TCP to `30431`), so normally nothing
needs opening. Set the link's network profile to **Private**, and allow the app if
Windows prompts. If a capture refuses to connect, add an outbound allow rule for
**TCP 30431**.

## 5. Install libiio + a client application

Install **ADI's libiio for Windows** (provides `iio_info`, `iio_readdev`, and the
backend DLLs) and a GUI such as **IIO Oscilloscope** or **Scopy**.

> ⚠️ **Version match.** The board's network `iiod` (port 30431) is the **0.26‑era**
> daemon. Use a **libiio 0.2x build / IIO Oscilloscope known‑good with this board**.
> A **libiio 1.x** client can connect but **return no data** against the 0.26 server
> (a confirmed version mismatch). When in doubt, use IIO Oscilloscope.

### Verify and capture
```
iio_info  -u ip:10.2.2.2
iio_readdev -u ip:10.2.2.2 -b 14336 -B ad7383-4 \
    voltage0 voltage1 voltage2 voltage3 voltage4 voltage5 voltage6 voltage7 \
    voltage8 voltage9 voltage10 voltage11 voltage12 voltage13 voltage14 voltage15
```
- `iio_info` should list the **`ad7383-4`** device (16 channels), plus context
  attributes like `fw_version`.
- `-B` enables buffered transfer — use it for sustained throughput.
- All 16 channels must be requested together (the device exposes a single
  all‑16 scan mask).

In **IIO Oscilloscope**: add a **Remote / Network** context at `ip:10.2.2.2`.

## 6. NIC tuning

One change is **required** for reliability; the rest is a verified reference
baseline to compare against if throughput falls short.

### Required: disable NIC power management

Windows defaults to allowing the OS to power the NIC down, which can stall a
long‑running acquisition when the machine idles. Turn it off:

**Device Manager → the 10 G adapter → Properties → Power Management →
un‑check "Allow the computer to turn off this device to save power"**

or from an **elevated** PowerShell:
```
Disable-NetAdapterPowerManagement -Name '<10G adapter name>'
```
(Non‑elevated shells silently leave it Enabled — verify with
`Get-NetAdapterPowerManagement`.)

### Verified reference baseline (full ADC rate)

This configuration (Intel **X550‑T2**, inbox driver 4.1.196.0) sustains the
DAQ's **full ADC output (~259 MB/s ≈ 2.1 Gbps) over `iiod`** — network capture
equals local capture rate, so nothing beyond it is needed:

| Advanced setting (Device Manager → Advanced) | Value |
|---|---|
| Jumbo Packet | **9014 Bytes** (§3 — the one throughput‑critical setting) |
| Receive Buffers | 4096 (max) |
| Transmit Buffers | 16384 (max) |
| Receive Side Scaling | Enabled (16 queues) |
| TCP/UDP/IPv4 Checksum Offload | Rx & Tx Enabled |
| Large Send Offload V2 (IPv4) | Enabled |
| Interrupt Moderation | Enabled (Rate: Extreme is fine for bulk streaming) |
| Flow Control | Rx & Tx Enabled (board sends no pause frames; harmless) |

OS defaults that should be left alone: TCP receive window auto‑tuning `normal`
(`netsh interface tcp show global`), RSS enabled globally. RSC is not exposed
by this driver and is not needed.

Quick audit of the installed adapter:
```
Get-NetAdapterAdvancedProperty -Name '<10G adapter name>' |
    Select-Object DisplayName, DisplayValue
Get-NetAdapterPowerManagement  -Name '<10G adapter name>'
```

---

## Troubleshooting

- **`ping 10.2.2.2` fails** → check the SFP+ cable/optics, that the adapter has the
  static `10.2.2.x/24` IP, and that the NIC link LED is up. The board's `sfp0` must
  be `up` (10 G eval link can be intermittent).
- **`iio_info` connects but shows no channels / no data** → libiio version mismatch
  (see §5); use the 0.26‑matched build / IIO Oscilloscope.
- **Low throughput** → Jumbo Packet not set to 9014 on the PC adapter (§3); compare
  the adapter against the reference baseline (§6).
- **Acquisition stalls after hours / link drops when the PC idles** → NIC power
  management still enabled (§6) — it defaults to on and needs an elevated shell
  or Device Manager to disable.
- **Can't reach it at all** → confirm you're on the **10 G** adapter's subnet, not the
  board's 1 G port (`10.0.0.2/24`), which is a separate interface.

---

## No‑10G alternatives

The same DAQ is reachable without a 10 G NIC:
- **1 GbE:** the board's `eth0` at `10.0.0.2/24` — same `iio_info -u ip:10.0.0.2`
  steps, lower ceiling (~0.94 Gbps).
- **USB‑C:** see `WINDOWS_USB_DRIVER_INSTALL.md` (needs the one‑time WinUSB driver).
