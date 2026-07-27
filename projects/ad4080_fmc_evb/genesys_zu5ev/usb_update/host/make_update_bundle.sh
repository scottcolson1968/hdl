#!/bin/bash
###############################################################################
# make_update_bundle.sh - build a wildcat_update_<version>.tar release bundle
#
# Usage: make_update_bundle.sh <version> <payload files...>
#   Bundles PRE-BUILT artifacts only (this script never builds). Output goes
#   to C:\wildcat_releases (override with OUT=... env). Payloads by basename:
#     BOOT.BIN  Image  system.dtb (any *.dtb)  VERSION.txt  rootfs.tar  post.sh
#
# The board-side engine always sets VERSION.txt line 1 to <version>; shipping
# a full VERSION.txt payload additionally replaces the body text (repo notes).
#
# Manifest records md5s + git provenance (hdl + linux trees) for traceability.
# Refuses to overwrite an existing release of the same version.
#
# Example (Git Bash):
#   ./make_update_bundle.sh 0.68 /home/.../BOOT.BIN
###############################################################################
set -eu
VER="${1:?version (e.g. 0.68)}"; shift
[ $# -ge 1 ] || { echo "need at least one payload file"; exit 1; }
OUT="${OUT:-/c/wildcat_releases}"
mkdir -p "$OUT"
BUN="$OUT/wildcat_update_${VER}.tar"
[ -e "$BUN" ] && { echo "REFUSED: $BUN already exists (bump the version)"; exit 1; }

HDL_GIT=$(git -C /d/hdl rev-parse --short HEAD 2>/dev/null || echo unknown)
HDL_DIRTY=$(git -C /d/hdl status --porcelain 2>/dev/null | grep -cE '^( M|M | A|A )' || true)
# kernel tree lives in WSL; git can't operate over the UNC path -> use wsl.exe
LNX_GIT=$(wsl.exe bash -c "git -C /home/scott/linux-adi rev-parse --short HEAD" 2>/dev/null | tr -d '\r\n' || true)
[ -n "$LNX_GIT" ] || LNX_GIT=unknown

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
{
    echo "magic=DAQ-UPDATE-V1"
    echo "version=$VER"
    echo "created=$(date '+%F %T')"
    echo "# hdl=$HDL_GIT (dirty_tracked=$HDL_DIRTY) linux=$LNX_GIT"
} > "$TMP/manifest.txt"

for src in "$@"; do
    [ -f "$src" ] || { echo "missing: $src"; exit 1; }
    name=$(basename "$src")
    case "$name" in
        BOOT.BIN|Image|system.dtb|VERSION.txt|rootfs.tar|post.sh) ;;
        *.dtb)  name=system.dtb ;;
        *)      echo "unrecognized payload: $name (allowed: BOOT.BIN Image system.dtb VERSION.txt rootfs.tar post.sh)"; exit 1 ;;
    esac
    cp -f "$src" "$TMP/$name"
    # freshness hint: warn on artifacts older than a day
    if find "$src" -mtime +1 2>/dev/null | grep -q .; then
        echo "WARNING: $name is >24h old ($(date -r "$src" '+%F %T' 2>/dev/null)) - is it the intended build?"
    fi
    ( cd "$TMP" && md5sum "$name" | sed 's/ \*/  /' ) >> "$TMP/manifest.txt"
done

tar -cf "$BUN" -C "$TMP" .
echo "=== $BUN ==="
tar -tf "$BUN" | sed 's/^/  /'
echo "--- manifest ---"
cat "$TMP/manifest.txt"
