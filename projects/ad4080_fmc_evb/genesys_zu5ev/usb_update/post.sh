#!/bin/bash
###############################################################################
# post.sh - activation hook for the Wildcat2 (AD4080) rootfs overlay.
#
# Runs on the board AFTER rootfs.tar is extracted to / (by daq-update), and is
# also invoked by install.sh during first-time bootstrap. Must be idempotent:
# it only fixes up permissions and reloads/enables the units the overlay owns.
#
# The overlay tar cannot be trusted to carry correct Unix modes (it is built on
# Windows/v9fs), so set the exec bits here explicitly.
###############################################################################
set -u

# --- executables shipped by the overlay
for f in /usr/local/bin/daq-update /usr/local/bin/daq-usb-update          /usr/local/bin/daq-adc-defaults; do
    [ -e "$f" ] && chmod 0755 "$f"
done

# --- reload systemd + udev so new/changed units and rules take effect
systemctl daemon-reload 2>/dev/null || true
udevadm control --reload-rules 2>/dev/null || true

# --- if a matching kernel modules tree was shipped in the overlay, refresh deps
for kd in /lib/modules/*/; do
    [ -d "${kd}kernel" ] && depmod "$(basename "$kd")" 2>/dev/null || true
done

# --- enable the persistent services the overlay owns (safe if already enabled).
#     daq-usb-update@.service is a udev-instantiated template, NOT enabled here.
#     Add units as they enter the overlay, e.g.:
#       systemctl enable --now wildcat-ap.service   2>/dev/null || true
#       systemctl enable --now daq-status-led.service 2>/dev/null || true
systemctl enable daq-adc-defaults.service 2>/dev/null || true

echo "post.sh: Wildcat2 overlay activated"
