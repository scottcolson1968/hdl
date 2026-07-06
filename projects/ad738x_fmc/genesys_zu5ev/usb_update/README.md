# DAQ USB auto-update (Genesys ZU)

Update the board's boot files **without removing the SD card and without any
PC/network knowledge**: copy one file onto a USB stick, plug it into the
board, wait for the green LED.

## Operator instructions (the whole procedure)

1. Copy the update file you were given (`wildcat_update_<version>.tar`) onto an
   ordinary **FAT32 USB stick** (top level, not in a folder).
2. Plug the stick into a **USB-A port** on the DAQ.
3. Watch the status LED:
   | LED | Meaning |
   |---|---|
   | **blue** (solid) | update in progress — do not power off. Stays blue through the reboot. |
   | **green** | done — the new version is fully booted and ready; safe to remove the stick |
   | **red** | update rejected/failed — board unchanged; remove the stick and check the `result-*.txt` file it wrote |
4. The sequence is **blue → red (booting) → green**. Green appears only once the
   new version is actually up, so waiting for green is always safe.

A `result-…txt` file is written back onto the stick either way — plug the
stick into any PC to read exactly what happened (old→new version or the
error).

Notes:
* Works from ANY installed version (upgrades and downgrades alike). A bundle
  matching the current version does nothing (that also makes it safe to leave
  the stick in across the reboot).
* An ordinary stick with no `wildcat_update_*.tar` on it is ignored completely
  (legacy `daq_update_*.tar` bundles are also accepted).
* Older builds without the RGB LED still update fine — use the result file.

## Making a bundle (developer side)

```bash
usb_update/host/make_update_bundle.sh 0.68 /path/to/BOOT.BIN [Image] [system.dtb]
```
Bundles land in **`C:\wildcat_releases`** (override with `OUT=`), which doubles
as the downgrade library — any archived bundle on a stick is a field rollback.
The script bundles **pre-built artifacts only** (it never builds), refuses
duplicate versions, warns on stale (>24 h) artifacts, and stamps the manifest
with hdl/linux git hashes for traceability. Any subset of payloads is fine
(BOOT.BIN-only is common). Optional payloads: `VERSION.txt` (replaces the body
text; line 1 is always set to the bundle version), `rootfs.tar` (extracted to
`/`; files it would overwrite are first saved to `/root/rootfs-bak-<ver>-<stamp>/`),
`post.sh` (runs after apply: service enables, deletions, package installs) —
the latter two are also how the updater updates itself.

## Filesystem (rootfs) changes — the overlay

Everything the DAQ *owns* on the rootfs lives in **`usb_update/overlay/`**, a
tree that mirrors absolute paths (`overlay/usr/local/bin/…`,
`overlay/etc/systemd/system/…`, `overlay/etc/udev/rules.d/…`, add
`overlay/etc/wildcat/…` for WiFi, etc.). It is the single source of truth for
both first-time bootstrap and updates, so a bootstrapped board and an updated
board converge to identical rootfs state.

To ship rootfs changes in a bundle:
```bash
usb_update/host/make_rootfs.sh rootfs.tar            # tar the whole overlay
usb_update/host/make_update_bundle.sh 0.72 Image BOOT.BIN system.dtb rootfs.tar \
    usb_update/post.sh
```
`post.sh` runs on the board after extraction to fix exec bits, `daemon-reload`,
reload udev, `depmod`, and enable the overlay's services (idempotent — ship the
**whole** overlay every time; it just converges state, and overwritten files are
backed up). `daq-update` remounts `/` rw for the rootfs/post phase and restores
ro if the board booted read-only.

**Kernel `Image` bumps:** ship the matching modules too, or `=m` modules (WiFi)
desync. Build them and fold them into the same `rootfs.tar`:
```bash
make modules_install INSTALL_MOD_PATH=/tmp/mods       # -> /tmp/mods/lib/modules/<ver>
usb_update/host/make_rootfs.sh rootfs.tar /tmp/mods   # overlay + /lib/modules/<ver>
```

## One-time board bootstrap (developer side)

The overlay lives on the rootfs, so each board needs it installed once:
```bash
usb_update/install.sh 10.0.0.2
```
This streams the whole overlay to the board and runs `post.sh`. After that, all
updates can be USB-stick only.

## Behavior / safety (engine: `overlay/usr/local/bin/daq-update`)

* manifest md5s verified **before** anything is touched
* current `/boot` files backed up to `/root/boot-bak-<oldver>-<stamp>/`
* written files **re-verified from the medium** after sync
* `VERSION.txt` first line updated to the bundle version (`fw_version`
  context attribute follows on next boot)
* same-version bundle → no-op (reboot-loop guard)
* failure leaves the board running; nothing is applied unless everything
  verified

Residual risk (same as any update method): a BOOT.BIN that is intact but
*functionally* bad still boots wrong — recover with the previous version's
bundle on a stick, or the `/root/boot-bak-*` copies over SSH, or SD pull as
last resort.
