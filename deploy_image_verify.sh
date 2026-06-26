#!/usr/bin/env bash
# Deploy new Image (device-level sampling_frequency); BOOT.BIN + dtb stay. Verify.
SSH="ssh -o ConnectTimeout=6 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@10.0.0.2"
SCP="scp -o ConnectTimeout=6 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
IMG=/home/scott/linux-adi/arch/arm64/boot/Image
$SSH uptime 2>/dev/null || { echo "BOARD UNREACHABLE"; exit 1; }
echo "=== deploy new Image ==="
$SCP "$IMG" root@10.0.0.2:/root/Image.new
$SSH "cp -n /boot/Image /root/Image.prev.bak 2>/dev/null; cp /root/Image.new /boot/Image; sync; echo deployed Image: \$(md5sum /boot/Image)"
echo "=== reboot ==="
$SSH "(sleep 1; reboot)>/dev/null 2>&1 &" 2>/dev/null
sleep 25
for i in $(seq 1 25); do $SSH uptime >/dev/null 2>&1 && break; sleep 6; done
sleep 5
echo "=== verify attribute layout ==="
$SSH "D=/sys/bus/iio/devices/iio:device1
echo -n 'device-level sampling_frequency: '; cat \$D/sampling_frequency 2>/dev/null || echo MISSING
echo -n 'per-type in_voltage_sampling_frequency (should be gone): '; (test -e \$D/in_voltage_sampling_frequency && echo STILL-PRESENT) || echo gone
echo -n 'channels: '; ls \$D/scan_elements/*_en 2>/dev/null | wc -l
echo -n 'dma-coherent: '; (cat /proc/device-tree/fpga-axi@0/dma-controller@a0000000/dma-coherent >/dev/null 2>&1 && echo yes) || echo no
echo -n '10G sfp0: '; ip -br link show sfp0 2>/dev/null | awk '{print \$2}'"
