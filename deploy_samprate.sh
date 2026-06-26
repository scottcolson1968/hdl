#!/usr/bin/env bash
# Deploy Image with default 4.000 MSPS / reported 4.096 MSPS sampling_frequency.
SSH="ssh -o ConnectTimeout=8 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@10.0.0.2"
SCP="scp -o ConnectTimeout=8 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
IMG=/home/scott/linux-adi/arch/arm64/boot/Image
$SSH uptime 2>/dev/null || { echo "BOARD UNREACHABLE"; exit 1; }
echo "=== deploy Image ==="
$SCP "$IMG" root@10.0.0.2:/root/Image.new
$SSH "cp -n /boot/Image /root/Image.bak.preamsps 2>/dev/null; cp /root/Image.new /boot/Image; sync; echo Image: \$(md5sum /boot/Image)"
echo "=== reboot ==="
$SSH "(sleep 1; reboot)>/dev/null 2>&1 &" 2>/dev/null
sleep 30
for i in $(seq 1 30); do $SSH uptime >/dev/null 2>&1 && break; sleep 6; done
sleep 5
echo "=== sampling_frequency (expect 4096000) ==="
$SSH 'D=/sys/bus/iio/devices/iio:device1
echo -n "sampling_frequency = "; cat $D/sampling_frequency
echo -n "sampling_frequency_available = "; cat $D/sampling_frequency_available 2>/dev/null
echo "--- write/read round-trip ---"
echo -n "write 4096000 -> "; echo 4096000 > $D/sampling_frequency 2>&1 && echo ok; echo -n "read back = "; cat $D/sampling_frequency
echo -n "write 2000000 -> "; echo 2000000 > $D/sampling_frequency 2>&1 && echo ok; echo -n "read back (expect truthful 2000000) = "; cat $D/sampling_frequency
echo -n "restore 4096000 -> "; echo 4096000 > $D/sampling_frequency 2>&1 && echo ok; echo -n "read back = "; cat $D/sampling_frequency'
echo "=== capture + health ==="
$SSH "echo -n cap:; timeout 8 iio_readdev -s 1024 -b 1024 ad7383-4 2>/dev/null|wc -c; echo -n ' sfp0:'; ip -br link show sfp0 2>/dev/null|awk '{print \$2}'; echo -n ' devs:'; iio_info 2>/dev/null|grep -c 'iio:device'"