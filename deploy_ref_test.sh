#!/usr/bin/env bash
# Deploy reference-bitstream BOOT.BIN + 0xA0 dtb (Image = our 6.12 16ch kernel,
# unchanged). Then 4-boot reliability test of the ADC chain.
SSH="ssh -o ConnectTimeout=6 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@10.0.0.2"
SCP="scp -o ConnectTimeout=6 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
BIN=$HOME/boot_genesys/BOOT.BIN
DTB=$HOME/linux-adi/arch/arm64/boot/dts/xilinx/zynqmp-genesys-zu-5ev-ad7383-4.dtb
$SSH uptime 2>/dev/null || { echo "BOARD UNREACHABLE - aborting"; exit 1; }
echo "=== deploy BOOT.BIN(ref bitstream) + dtb(0xA0) ==="
$SCP "$BIN" root@10.0.0.2:/root/BOOT.BIN.ref
$SCP "$DTB" root@10.0.0.2:/root/system.dtb.ref
$SSH "cp /root/BOOT.BIN.ref /boot/BOOT.BIN; cp /root/system.dtb.ref /boot/system.dtb; sync; echo deployed:; md5sum /boot/BOOT.BIN /boot/system.dtb /boot/Image"
echo "=== reliability test (4 boots) ==="
ok=0; fail=0
for boot in 1 2 3 4; do
  $SSH "(sleep 1; reboot)>/dev/null 2>&1 &" 2>/dev/null
  sleep 25
  for i in $(seq 1 25); do $SSH uptime >/dev/null 2>&1 && break; sleep 6; done
  sleep 6
  adc=$($SSH "cat /sys/bus/iio/devices/iio:device1/name 2>/dev/null" 2>/dev/null)
  ch=$($SSH "ls /sys/bus/iio/devices/iio:device1/scan_elements/*_en 2>/dev/null | wc -l" 2>/dev/null)
  pwm=$($SSH "dmesg 2>/dev/null | grep -c 'failed to get PWM'" 2>/dev/null)
  if [ "$adc" = "ad7383-4" ]; then echo "boot $boot: OK   (ch=$ch)"; ok=$((ok+1)); else echo "boot $boot: FAIL (adc='$adc' pwm=$pwm)"; fail=$((fail+1)); fi
done
echo "=== RESULT: $ok OK / $fail FAIL of 4 ==="
