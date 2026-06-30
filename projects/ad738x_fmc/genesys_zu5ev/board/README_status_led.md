# DAQ "safe to connect" RGB status LED (LD5)

Lights the on-board RGB LED (LD5) to tell an operator when a PC libiio client
(USB or network) may connect:

| Color | Meaning |
|-------|---------|
| **Red**   | Booting — not ready |
| **Blue**  | System up, `iiod` starting / not yet accepting clients |
| **Green** | **Safe to connect** — `iiod` is listening **and** `/dev/iio:device0` is present |

## How it works
- **PL:** RGB LED pins C9/B9/A8 are driven from PS EMIO GPIO `o[46:44]`
  (`system_top.v` + `system_constr.xdc`). *Requires the bitstream rebuild.*
- **Kernel:** `gpio-leds` node (appended to
  `zynqmp-genesys-zu-5ev-ad7383-4.dts`) exposes `daq:red/green/blue` under
  `/sys/class/leds/`. Red is `default-state = "on"` so it lights at early boot.
  *Requires the rebuilt DTB.*
- **Userspace:** `daq-status-led.service` runs `daq_status_led.sh`, which sets
  blue on start and flips to green once it confirms an iiod transport is
  actually listening (network port 30431/30432, or USB FFS with a configured
  UDC).

## Install on the board (after deploying the new BOOT.BIN + DTB)
```sh
# copy the two files to the board (ext4 rootfs, not the FAT boot part)
scp daq_status_led.sh      root@10.0.0.2:/usr/local/bin/
scp daq-status-led.service root@10.0.0.2:/etc/systemd/system/

ssh root@10.0.0.2 '
  chmod +x /usr/local/bin/daq_status_led.sh
  systemctl daemon-reload
  systemctl enable --now daq-status-led.service
  sync
'
```

## Verify
```sh
ssh root@10.0.0.2 '
  ls /sys/class/leds | grep daq        # daq:red daq:green daq:blue
  systemctl status daq-status-led --no-pager
  # manual test (overridden by the service ~2 s later):
  echo 1 > /sys/class/leds/daq:green/brightness
'
```
With a client connected and streaming, LD5 should be solid **green**. Stop
`iiod026`/`iiod_ffs` and it should fall back to **blue**.

## If the colors are inverted
LD5 is then active-low. Change `GPIO_ACTIVE_HIGH` → `GPIO_ACTIVE_LOW` for all
three entries in the `leds` node of the DTS and rebuild **only the DTB** (no
bitstream rebuild needed).
