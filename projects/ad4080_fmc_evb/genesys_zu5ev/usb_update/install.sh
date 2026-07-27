#!/bin/bash
###############################################################################
# install.sh - one-time bootstrap of the Wildcat rootfs overlay onto a board.
# Usage: ./install.sh [board-ip]   (default 10.0.0.2; needs ssh key auth)
#
# Pushes the entire overlay/ tree to its mirrored absolute paths and runs the
# same post.sh activation the USB updater uses, so a freshly-bootstrapped board
# and an updated board converge to identical rootfs state.
###############################################################################
set -eu
B="root@${1:-10.0.0.2}"
D="$(cd "$(dirname "$0")" && pwd)"
OVL="$D/overlay"
S="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=8 -o BatchMode=yes"

[ -d "$OVL" ] || { echo "no overlay dir at $OVL"; exit 1; }

# stream the overlay straight into / on the board (same shape as rootfs.tar)
tar -cf - --owner=0 --group=0 -C "$OVL" . | ssh $S "$B" 'tar -xf - -C /'

# activate with the shared post.sh
scp $S "$D/post.sh" "$B":/tmp/wildcat-post.sh
ssh $S "$B" 'bash /tmp/wildcat-post.sh; rm -f /tmp/wildcat-post.sh; \
    echo "overlay installed. Plug a FAT32 stick with wildcat_update_<v>.tar to update."'
