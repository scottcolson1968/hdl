#!/usr/bin/env bash
# Reboot the board N times; each boot check whether the ADC chain (ad7383-4 16ch)
# comes up or hits 'failed to get PWM'. Tests reliability of the coherent build.
SSH="ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@10.0.0.2"
ok=0; fail=0
for boot in 1 2 3 4; do
  echo "=== boot $boot ==="
  $SSH "(sleep 1; reboot)>/dev/null 2>&1 &" 2>/dev/null
  sleep 25
  for i in $(seq 1 25); do $SSH uptime >/dev/null 2>&1 && break; sleep 6; done
  sleep 6
  adc=$($SSH "cat /sys/bus/iio/devices/iio:device1/name 2>/dev/null" 2>/dev/null)
  ch=$($SSH "ls /sys/bus/iio/devices/iio:device1/scan_elements/*_en 2>/dev/null | wc -l" 2>/dev/null)
  pwm=$($SSH "dmesg 2>/dev/null | grep -c 'failed to get PWM'" 2>/dev/null)
  if [ "$adc" = "ad7383-4" ]; then
    echo "boot $boot: OK  (adc=$adc ch=$ch)"; ok=$((ok+1))
  else
    echo "boot $boot: FAIL (adc='$adc' pwm_fail=$pwm)"; fail=$((fail+1))
  fi
done
echo "=== RESULT: $ok OK / $fail FAIL of 4 boots ==="
