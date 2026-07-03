#!/bin/bash
###############################################################################
# install.sh - one-time bootstrap of the DAQ USB auto-updater onto a board
# Usage: ./install.sh [board-ip]   (default 10.0.0.2; needs ssh key auth)
###############################################################################
set -eu
B="root@${1:-10.0.0.2}"
D="$(cd "$(dirname "$0")" && pwd)"
S="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=8 -o BatchMode=yes"

scp $S "$D/board/daq-update" "$D/board/daq-usb-update" "$B":/usr/local/bin/
scp $S "$D/board/daq-usb-update@.service" "$B":/etc/systemd/system/
scp $S "$D/board/99-daq-usb-update.rules" "$B":/etc/udev/rules.d/
ssh $S "$B" '
    chmod +x /usr/local/bin/daq-update /usr/local/bin/daq-usb-update
    systemctl daemon-reload
    udevadm control --reload-rules
    echo "installed: $(ls -la /usr/local/bin/daq-update /usr/local/bin/daq-usb-update | awk "{print \$NF}")"
    echo "udev rule + service in place. Plug a FAT32 stick with daq_update_<v>.tar to update."
'
