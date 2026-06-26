#!/usr/bin/env bash
# Deploy coherent build: BOOT.BIN (HPC0 SmartConnect bitstream) + coherent dtb
# (dma-coherent + cci). Image unchanged. Backs up the non-coherent versions.
set -eo pipefail
BIN=$HOME/boot_genesys/BOOT.BIN
DTB=$HOME/linux-adi/arch/arm64/boot/dts/xilinx/zynqmp-genesys-zu-5ev-ad7383-4.dtb
SSH="ssh -o ConnectTimeout=8 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
SCP="scp -o ConnectTimeout=8 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
echo "=== local md5 ==="; md5sum "$BIN" "$DTB"
$SCP "$BIN" root@10.0.0.2:/root/BOOT.BIN.coh
$SCP "$DTB" root@10.0.0.2:/root/system.dtb.coh
$SSH root@10.0.0.2 'bash -s' <<'REMOTE'
set -e
echo "transferred:"; md5sum /root/BOOT.BIN.coh /root/system.dtb.coh
cp -n /boot/BOOT.BIN   /root/BOOT.BIN.noncoh.bak   2>/dev/null || true
cp -n /boot/system.dtb /root/system.dtb.noncoh.bak 2>/dev/null || true
cp /root/BOOT.BIN.coh   /boot/BOOT.BIN
cp /root/system.dtb.coh /boot/system.dtb
sync
echo "deployed /boot:"; md5sum /boot/BOOT.BIN /boot/system.dtb /boot/Image
REMOTE
echo DEPLOY_DONE
