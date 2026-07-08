# AD7383-4 FMC Daughtercard — Initial Bring-Up

One-time procedure to bring up a **new** EVAL-AD7383-4FMCZ daughtercard on the
Genesys ZU host board. Do this once per new card, before first use.

There are two things every new card needs:

1. The board **jumpers/links** set correctly (Step 1).
2. The card's FMC **EEPROM patched** so it stops requesting more VADJ current than
   the host can supply — otherwise the board's power controller latches a fault
   and the red LED stays on (Steps 3–5).

---

## Step 1 — Set the jumpers

With the board **powered off**, set these links:

| Link | Position |
|------|----------|
| LK1  | 2–3      |
| LK2  | 2–3      |
| LK3  | 1–2      |
| LK4  | 3–4      |
| LK5  | 5–6      |
| LK6  | 1–2      |

Double-check each one before proceeding.

## Step 2 — Fit the daughtercard

With the board still powered off, seat the EVAL-AD7383-4FMCZ onto the FMC
connector and secure it.

## Step 3 — Power on (expect the fault LED on a new card)

Power on the board. **A brand-new, unpatched card will trip the red fault LED.**

This is expected and normal. A factory card's FMC EEPROM (its FRU / VADJ
"DC Load" record) asks for **4000 mA** on the adjustable rail (VADJ), which is
over the Genesys ZU's **~2.1 A** VADJ budget. The board's power management
controller (PMCU) reads this at power-up, sees the request exceeds the budget,
and latches an over-current fault — that's the red LED. The rest of the board
still boots normally; only the daughtercard rail stays off.

## Step 4 — Patch the card with `fmc-vadj-fix`

Log into the board (SSH to its management IP, or the serial console) and run,
from any directory:

```
fmc-vadj-fix
```

Expected output on a new card:

```
FMC EEPROM: /sys/bus/i2c/devices/5-0051/eeprom
current VADJ max-current request: 4000 mA
patching: maxI 4000 -> 2000 mA;  recCk -> 0xe4  hdrCk -> 0x0b
backup saved: /root/fmc_eeprom_backup_YYYYMMDD_HHMMSS.bin
OK: VADJ max-current now 2000 mA, checksums updated and verified.
>>> POWER-CYCLE the board to clear the VADJ fault LED. <<<
```

The tool lowers the card's VADJ current request from 4000 mA to **2000 mA**
(within budget), fixes the record's checksums, and verifies the write. It first
saves a full backup of the original EEPROM to `/root/`. It is **idempotent** —
running it on an already-patched card just prints "already within budget" and
changes nothing.

## Step 5 — Power-cycle

**Fully power-cycle the board.** The PMCU only reads the FMC EEPROM at power-up,
so a cold power cycle is required for the change to take effect (a warm reboot is
not enough).

## Step 6 — Verify

After the power cycle, the **red fault LED should stay off** and VADJ powers up.
Confirm the ADC enumerated:

```
iio_info | grep -i ad7383           # or:
cat /sys/bus/iio/devices/iio:device0/name          # -> ad7383-4
```

The card is now ready for acquisition.

---

## Reference

**What the tool changes:** the EVAL-AD7383-4FMCZ EEPROM is a 24c02 at I²C address
`0x51` behind the on-board PCA9548 mux (channel 4). Its IPMI FRU multirecord for
VADJ ("DC Load", at offset `0xae`) carries a max-current field at bytes
`0xbe/0xbf`. `fmc-vadj-fix` changes it from `0x0fa0` (4000 mA) to `0x07d0`
(2000 mA) and recomputes the record and header checksums. Nothing else on the
card is touched.

**Backup / restore:** every run saves `/root/fmc_eeprom_backup_<timestamp>.bin`
(a full 256-byte image of the original EEPROM). To restore a card to its factory
state:

```
dd if=/root/fmc_eeprom_backup_<timestamp>.bin of=/sys/bus/i2c/devices/5-0051/eeprom bs=256
```

(Replace the `5-0051` bus number if the tool reported a different `FMC EEPROM:`
path.)

**Troubleshooting**

| Symptom | Cause / action |
|---|---|
| `FMC EEPROM not found …` | No card fitted, or it hasn't probed. Confirm the card is seated and the board fully booted, then retry. |
| Red LED still on after patch + power-cycle | Make sure it was a **cold power cycle**, not a warm reboot. Re-run `fmc-vadj-fix`; it will report the current value — it should read 2000 mA. |
| `record @0xae is not a DC-Load record …` | The card's EEPROM layout isn't the expected EVAL-AD7383-4FMCZ FRU. The tool aborts without writing. Do not force it; check the card. |
