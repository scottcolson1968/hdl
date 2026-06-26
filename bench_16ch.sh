#!/usr/bin/env bash
# Throughput benchmark, 16ch-format 4ch build. Correct rate attr = in_voltage_sampling_frequency.
SSH="ssh -o ConnectTimeout=8 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
$SSH root@10.0.0.2 'bash -s' <<'REMOTE'
F=/sys/bus/iio/devices/iio:device1
echo 4000000 > $F/in_voltage_sampling_frequency
echo "rate set to: $(cat $F/in_voltage_sampling_frequency)"
echo "=== LOCAL throughput: 8M samples -> /dev/null ==="
t0=$(date +%s.%N)
iio_readdev -s 8000000 -b 262144 ad7383-4 > /dev/null 2>/tmp/b.err
rc=$?
t1=$(date +%s.%N)
awk -v n=8000000 -v t0=$t0 -v t1=$t1 'BEGIN{dt=t1-t0; printf "elapsed=%.3fs  scans/s=%.3f M  MiB/s=%.1f (offered@4MHz=244)\n", dt, n/1e6/dt, n*64/1048576/dt}'
echo "rc=$rc stderr:"; head -2 /tmp/b.err
REMOTE
