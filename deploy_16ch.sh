#!/usr/bin/env bash
# Deploy the 4ch->16ch build to the 4ch board: new BOOT.BIN (streamToSteam
# bitstream) + new Image (16ch ad7380 driver). dtb unchanged. Backs up first.
set -eo pipefail
BIN=$HOME/boot_genesys/BOOT.BIN
IMG=$HOME/linux-adi/arch/arm64/boot/Image
SSH="ssh -o ConnectTimeout=8 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
SCP="scp -o ConnectTimeout=8 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
echo "=== local md5 ===" ; md5sum "$BIN" "$IMG"
echo "=== scp -> /root (ext4) ==="
$SCP "$BIN" root@10.0.0.2:/root/BOOT.BIN.16ch
$SCP "$IMG" root@10.0.0.2:/root/Image.16ch
echo "=== remote: space, backup, deploy onto /boot ==="
$SSH root@10.0.0.2 'bash -s' <<'REMOTE'
set -e
echo "boot space:"; df -h /boot | tail -1
echo "transferred:"; md5sum /root/BOOT.BIN.16ch /root/Image.16ch
cp -n /boot/BOOT.BIN /root/BOOT.BIN.4ch.bak 2>/dev/null || true
cp -n /boot/Image    /root/Image.4ch.bak    2>/dev/null || true
echo "backups:"; ls -la /root/BOOT.BIN.4ch.bak /root/Image.4ch.bak 2>/dev/null
cp /root/BOOT.BIN.16ch /boot/BOOT.BIN
cp /root/Image.16ch    /boot/Image
sync
echo "deployed /boot md5:"; md5sum /boot/BOOT.BIN /boot/Image
REMOTE
echo DEPLOY_DONE
