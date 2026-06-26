#!/usr/bin/env bash
# Deploy MAX_NUM_CHANNELS=16 Image, reboot, run iio_info (panic test), verify alive.
SSH="ssh -o ConnectTimeout=6 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@10.0.0.2"
SCP="scp -o ConnectTimeout=6 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
IMG=/home/scott/linux-adi/arch/arm64/boot/Image
$SSH uptime 2>/dev/null || { echo "BOARD UNREACHABLE"; exit 1; }
echo "=== deploy fixed Image ==="
$SCP "$IMG" root@10.0.0.2:/root/Image.new
$SSH "cp -n /boot/Image /root/Image.panicky.bak 2>/dev/null; cp /root/Image.new /boot/Image; sync; echo Image: \$(md5sum /boot/Image)"
echo "=== reboot ==="
$SSH "(sleep 1; reboot)>/dev/null 2>&1 &" 2>/dev/null
sleep 25
for i in $(seq 1 25); do $SSH uptime >/dev/null 2>&1 && break; sleep 6; done
sleep 5
echo "=== iio_info (THE panic test) ==="
$SSH "timeout 25 iio_info > /tmp/ii.out 2>&1; echo iio_info-exit=\$?; echo lines=\$(wc -l < /tmp/ii.out)"
echo "=== board still alive after iio_info? (no panic if this responds) ==="
$SSH "uptime | sed s/.*up/UP/; echo -n chans:; ls /sys/bus/iio/devices/iio:device1/scan_elements/*_en 2>/dev/null | wc -l; echo -n sfreq:; cat /sys/bus/iio/devices/iio:device1/sampling_frequency 2>/dev/null; echo; echo -n cap1024:; timeout 8 iio_readdev -s 1024 -b 1024 ad7383-4 2>/dev/null | wc -c"
