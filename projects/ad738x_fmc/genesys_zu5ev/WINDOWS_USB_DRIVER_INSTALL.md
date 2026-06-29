# Installing the Windows USB Driver (IIO over USB)

The DAQ connects to a Windows PC over USB-C and presents itself as a composite USB
device named **`IIO-USB-CDC-ACM`** (USB ID **`0456:B671`**) with two interfaces:

| Interface | Shows in Windows as | Purpose | Driver needed |
|-----------|---------------------|---------|---------------|
| **IIO** (Interface 0) | `IIO` | Measurement data path (libiio / IIO Oscilloscope / your app) | **WinUSB** — install manually, one time |
| Serial Console (Interface 1) | `Generic Serial Console (COMx)` | Debug serial console | Auto-installed by Windows (COM port). **No action.** |

Windows does **not** auto-install a driver for the **IIO** data interface, so you must
bind the **WinUSB** driver to it once per PC. After that, Windows remembers it.

> If you only need the debug console, nothing is required — the COM port installs
> automatically. The steps below are for the **data** path.

---

## Install with Zadig (recommended)

1. **Download Zadig** from <https://zadig.akeo.ie> — it's a single `.exe`, no installation.
   **Right-click → Run as administrator.**

2. **Connect the DAQ** to the PC with a USB-C cable (a USB 3.0 / SuperSpeed port is
   recommended for full throughput). Wait ~5 seconds for Windows to detect it.

3. In Zadig, open **Options → List All Devices** (checkbox).

4. In the device drop-down, select **`IIO`**
   (it may appear as `IIO` or `IIO-USB-CDC-ACM (Interface 0)`).
   - Confirm the **USB ID reads `0456 B671`**.
   - ⚠️ **Pick the `IIO` interface — NOT `Generic Serial Console`.** Do not change the
     serial-console interface.

5. Make sure the target driver box (right of the green arrow) shows **`WinUSB`**
   (use the ▲▼ arrows if it doesn't).

6. Click **Install Driver** (or **Replace Driver** if one is already present).
   Wait for **"The driver was installed successfully."**

That's it. The driver persists across reboots and unplugging.

---

## Verify it worked

**Device Manager** (`devmgmt.msc`):
- Under **Universal Serial Bus devices** → **`IIO`**, driver = WinUSB, no yellow warning.
- Under **Ports (COM & LPT)** → the serial console as a COM port (this is normal/optional).

**With libiio tools** (if installed):
```
iio_info -S usb
```
You should see a context such as:
```
0456:b671 (Analog Devices Inc. IIO-USB-CDC-ACM), serial=... [usb:1.X.0]
```
Then connect your application using the USB backend, e.g.:
```
iio_info  -u usb:1.X.0
iio_readdev -u usb:1.X.0 -b 14336 -B ad7383-4 voltage0 ... voltage15
```
(The `usb:1.X.0` address may change on re-plug; re-run `iio_info -S usb` to find it.)

---

## Troubleshooting

- **`IIO` shows under "Other devices" with a yellow `!`** → the WinUSB driver isn't
  installed yet. Run Zadig as above.
- **Don't see `IIO` in Zadig** → make sure **Options → List All Devices** is checked,
  and the board is plugged in and powered.
- **Installed WinUSB on the wrong interface** (e.g., the serial console) → re-run Zadig,
  select the correct **`IIO`** interface, and Replace Driver. If the COM port disappeared,
  Replace its driver back to **USB Serial (CDC)** in Zadig, or just unplug/replug.
- **Admin required** — driver installation needs Administrator rights.
- **USB 2.0 vs 3.0** — the IIO/WinUSB path works on either; use a USB 3.0 (SuperSpeed)
  port and cable for full data rate.

---

## No-driver alternative: Ethernet

The DAQ also serves IIO over its **network** interfaces, which needs **no USB driver**:
```
iio_info -u ip:<board-ip>
```
Use this if you cannot install drivers on the PC, or alongside USB.
