#!/usr/bin/env bash
SSH="ssh -o ConnectTimeout=8 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
$SSH root@10.0.0.2 'bash -s' <<'REMOTE'
echo "=== dma-coherent in running DT ==="
find /proc/device-tree -name dma-coherent 2>/dev/null | sed 's#/proc/device-tree/##'
echo "count: $(find /proc/device-tree -name dma-coherent 2>/dev/null | wc -l)"
echo "=== rx_dma node props ==="
n=$(find /proc/device-tree -type d -name '*84a30000*' 2>/dev/null | head -1)
echo "node: $n"; ls "$n" 2>/dev/null | tr '\n' ' '; echo
echo "=== which dtb did u-boot load? (boot.scr) ==="
strings /boot/boot.scr 2>/dev/null | grep -iE 'dtb|fdt|system' | head -3
echo "=== LOCAL throughput (coherent) ==="
F=/sys/bus/iio/devices/iio:device1
echo 4000000 > $F/in_voltage_sampling_frequency
echo "rate: $(cat $F/in_voltage_sampling_frequency)"
t0=$(date +%s.%N)
iio_readdev -s 8000000 -b 262144 ad7383-4 > /dev/null 2>/tmp/c.err
t1=$(date +%s.%N)
awk -v n=8000000 -v t0=$t0 -v t1=$t1 'BEGIN{dt=t1-t0; printf "LOCAL: %.1f MiB/s @ %.3f Mscans/s\n", n*64/1048576/dt, n/1e6/dt}'
echo "err: $(head -1 /tmp/c.err)"
REMOTE
