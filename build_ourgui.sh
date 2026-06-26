#!/usr/bin/env bash
# dtb (our GUI build's 0xA0 addresses, fpga-axi enabled) + BOOT.BIN with the
# reference FPD/HPC0 FSBL + our GUI genesys bitstream (X0Y7 GT, SYNC_TRANSFER_START=0).
set -eo pipefail
cd /home/scott/linux-adi
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- xilinx/zynqmp-genesys-zu-5ev-ad7383-4.dtb 2>&1 | tail -1
echo "dtb: $(md5sum arch/arm64/boot/dts/xilinx/zynqmp-genesys-zu-5ev-ad7383-4.dtb)"
R=/mnt/c/share/ad738x_fmc/gzu_5ev/ALERTSPIN0_NUMOFSDI4/ad738x_gzu6
FSBL="$R/ad738x/zynqmp_fsbl/fsbl_a53.elf" PMUFW="$R/ad738x/zynqmp_pmufw/pmufw.elf" \
  bash "$HOME/make_boot.sh" 2>&1 | grep -iE "generated successfully|MISSING|ERROR" | head
echo "BOOT.BIN: $(md5sum "$HOME/boot_genesys/BOOT.BIN")"
echo "bitstream packaged (our GUI build d84a8ccc): $(md5sum /mnt/d/hdl/projects/ad738x_fmc/genesys_zu5ev/ad738x_fmc_genesys_zu5ev.runs/impl_1/system_top.bit)"
