#!/usr/bin/env bash
# Deploy dtb with ams_ps enabled. Verify xilinx-ams (device0) reads WITHOUT hang
# and matches reference layout: device0=xilinx-ams, device1=ad7383-4.
SSH="ssh -o ConnectTimeout=8 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@10.0.0.2"
SCP="scp -o ConnectTimeout=8 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
DTB=/home/scott/linux-adi/arch/arm64/boot/dts/xilinx/zynqmp-genesys-zu-5ev-ad7383-4.dtb
$SSH uptime 2>/dev/null || { echo "BOARD UNREACHABLE"; exit 1; }
echo "=== deploy dtb (ams_ps okay) ==="
$SCP "$DTB" root@10.0.0.2:/boot/system.dtb.new
$SSH "cp -n /boot/system.dtb /boot/system.dtb.bak.noams 2>/dev/null; cp /boot/system.dtb.new /boot/system.dtb; sync; echo dtb: \$(md5sum /boot/system.dtb)"
echo "=== reboot ==="
$SSH "(sleep 1; reboot)>/dev/null 2>&1 &" 2>/dev/null
sleep 30
for i in $(seq 1 30); do $SSH uptime >/dev/null 2>&1 && break; sleep 6; done
sleep 5
echo "=== iio devices (expect device0=xilinx-ams, device1=ad7383-4) ==="
$SSH 'for d in /sys/bus/iio/devices/iio:device*; do echo "$d -> $(cat $d/name)"; done'
echo "=== AMS raw read MUST return (no D-state hang) ==="
$SSH 'A=/sys/bus/iio/devices/iio:device0; echo -n "label0="; cat $A/in_voltage0_label 2>/dev/null; echo -n " raw0="; timeout 6 cat $A/in_voltage0_raw 2>&1; echo " rc=$?"; echo -n "temp0="; timeout 6 cat $A/in_temp0_raw 2>&1; echo " rc=$?"'
echo "=== iio_info full run (exit 0, no hang) ==="
$SSH "timeout 30 iio_info >/tmp/ii.out 2>&1; echo iio_info-exit=\$?; echo lines=\$(wc -l < /tmp/ii.out); grep -E 'iio:device[01]:' /tmp/ii.out"
echo "=== ADC + 10G still healthy; D-state count ==="
$SSH "uptime|sed s/.*up/UP/; echo -n adc-name@device1:; cat /sys/bus/iio/devices/iio:device1/name; echo -n ' chans:'; ls /sys/bus/iio/devices/iio:device1/scan_elements/in_voltage*_en 2>/dev/null|wc -l; echo -n ' cap:'; timeout 8 iio_readdev -s 1024 -b 1024 ad7383-4 2>/dev/null|wc -c; echo -n ' sfp0:'; ip -br link show sfp0 2>/dev/null|awk '{print \$2}'; echo -n ' Dprocs:'; ps aux|awk '\$8 ~ /D/{n++}END{print n+0}'"