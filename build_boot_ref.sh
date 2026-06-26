#!/usr/bin/env bash
# BOOT.BIN with the reference FSBL+PMUFW+bitstream (PS config matched to the
# reference bitstream's FPD-control + HPC0 topology). bl31/u-boot/dt.dtb default.
set -eo pipefail
R=/mnt/c/share/ad738x_fmc/gzu_5ev/ALERTSPIN0_NUMOFSDI4/ad738x_gzu6
FSBL=$R/ad738x/zynqmp_fsbl/fsbl_a53.elf
PMUFW=$R/ad738x/zynqmp_pmufw/pmufw.elf
BIT=/mnt/d/hdl/projects/ad738x_fmc/gzu_5ev/ALERTSPIN0_NUMOFSDI4/ad738x_fmc_gzu_5ev.runs/impl_1/system_top.bit
echo "FSBL exists: $(test -f "$FSBL" && echo yes); PMUFW: $(test -f "$PMUFW" && echo yes); BIT: $(test -f "$BIT" && echo yes)"
FSBL="$FSBL" PMUFW="$PMUFW" BIT="$BIT" bash "$HOME/make_boot.sh" 2>&1 | grep -iE "generated successfully|MISSING|ERROR" | head
echo "BOOT.BIN: $(md5sum "$HOME/boot_genesys/BOOT.BIN")"
