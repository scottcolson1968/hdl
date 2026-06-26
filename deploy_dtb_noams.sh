#!/usr/bin/env bash
# Deploy AMS-disabled dtb, force-reboot (D-state iio_info procs block clean reboot),
# then confirm iio_info runs clean (no device0 xilinx-ams) + ADC still good.
SSH="ssh -o ConnectTimeout=6 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@10.0.0.2"
SCP="scp -o ConnectTimeout=6 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
DTB=/home/scott/linux-adi/arch/arm64/boot/dts/xilinx/zynqmp-genesys-zu-5ev-ad7383-4.dtb
$SSH uptime 2>/dev/null || { echo "BOARD UNREACHABLE"; exit 1; }
echo "=== deploy dtb ==="
$SCP "$DTB" root@10.0.0.2:/boot/system.dtb.new
$SSH "cp -n /boot/system.dtb /boot/system.dtb.bak.preams 2>/dev/null; cp /boot/system.dtb.new /boot/system.dtb; sync; echo dtb: \$(md5sum /boot/system.dtb)"
echo "=== force reboot (clears wedged AMS D-state procs) ==="
$SSH "(sleep 1; reboot -f)>/dev/null 2>&1 &" 2>/dev/null
sleep 30
for i in $(seq 1 30); do $SSH uptime >/dev/null 2>&1 && break; sleep 6; done
sleep 5
echo "=== iio devices (xilinx-ams should be GONE) ==="
$SSH 'for d in /sys/bus/iio/devices/iio:device*; do echo "$d -> $(cat $d/name)"; done'
echo "=== iio_info (THE test: must complete, no hang/segfault) ==="
$SSH "timeout 30 iio_info >/tmp/ii.out 2>&1; echo iio_info-exit=\$?; echo lines=\$(wc -l < /tmp/ii.out); grep -c ad7383-4 /tmp/ii.out | sed 's/^/ad7383-4-matches=/'"
echo "=== board still healthy + ADC capture ==="
$SSH "uptime | sed s/.*up/UP/; echo -n chans:; ls /sys/bus/iio/devices/iio:device*/scan_elements/in_voltage*_en 2>/dev/null | wc -l; echo -n sfreq:; cat /sys/bus/iio/devices/iio:device0/sampling_frequency 2>/dev/null; echo; echo -n cap64k:; timeout 8 iio_readdev -s 1024 -b 1024 ad7383-4 2>/dev/null | wc -c; echo; echo -n sfp0:; ip -br link show sfp0 2>/dev/null | awk '{print \$2}'; echo -n ' D-state-procs:'; ps aux | awk '\$8 ~ /D/ {n++} END{print n+0}'"