#!/bin/bash
###############################################################################
# make_rootfs.sh - build rootfs.tar from the Wildcat overlay tree.
#
# Usage: make_rootfs.sh [output.tar] [extra-root-dir ...]
#   Default output: ./rootfs.tar
#   The overlay/ tree (usb_update/overlay) mirrors absolute rootfs paths; every
#   file is tarred with a ./-relative path so daq-update can 'tar -xf -C /'.
#   Ownership is forced to root:root. Modes from the overlay are NOT trusted
#   (built on Windows/v9fs) - post.sh sets exec bits on the board.
#
#   Optional extra-root-dir args let you fold in generated content that doesn't
#   live in git, staged the same mirrored way. The classic case is a matching
#   kernel modules tree for an Image bump:
#     make modules_install INSTALL_MOD_PATH=/tmp/mods   # -> /tmp/mods/lib/modules/<ver>
#     make_rootfs.sh rootfs.tar /tmp/mods
#   so /lib/modules/<ver> ships alongside the new Image and =m modules match.
#
# Pair the result with post.sh in a bundle:
#   make_update_bundle.sh <ver> Image BOOT.BIN system.dtb rootfs.tar post.sh
###############################################################################
set -eu
OUT="${1:-$PWD/rootfs.tar}"
[ $# -ge 1 ] && shift || true      # remaining "$@" = optional extra mirrored roots

HERE="$(cd "$(dirname "$0")/.." && pwd)"        # usb_update/
OVL="$HERE/overlay"
[ -d "$OVL" ] || { echo "no overlay dir at $OVL"; exit 1; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
# stage overlay
cp -a "$OVL/." "$TMP/"
# stage any extra mirrored roots (e.g. modules_install output)
for extra in "$@"; do
    [ -d "$extra" ] || { echo "extra root not a dir: $extra"; exit 1; }
    cp -a "$extra/." "$TMP/"
done

( cd "$TMP" && tar -cf "$OUT" --owner=0 --group=0 . )
echo "=== $OUT ==="
tar -tvf "$OUT"
