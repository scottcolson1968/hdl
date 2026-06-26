#!/usr/bin/env bash
# Redeploy BOOT.BIN only (SYNC_TRANSFER_START=0 bitstream). Image/dtb unchanged.
set -eo pipefail
BIN=$HOME/boot_genesys/BOOT.BIN
SSH="ssh -o ConnectTimeout=8 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
SCP="scp -o ConnectTimeout=8 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
echo "=== local md5 ===" ; md5sum "$BIN"
$SCP "$BIN" root@10.0.0.2:/root/BOOT.BIN.v2
$SSH root@10.0.0.2 'bash -s' <<'REMOTE'
set -e
echo "transferred: $(md5sum /root/BOOT.BIN.v2)"
cp -n /boot/BOOT.BIN /root/BOOT.BIN.16ch-v1.bak 2>/dev/null || true
cp /root/BOOT.BIN.v2 /boot/BOOT.BIN
sync
echo "deployed /boot: $(md5sum /boot/BOOT.BIN)"
REMOTE
echo DEPLOY_DONE
