#!/bin/bash
# make_boot.sh -- build a BOOTABLE BOOT.BIN for the Wildcat2 / AD4080 Genesys ZU-5EV.
#
# THIS IS THE ONLY CORRECT RECIPE. It uses the AUTHORITATIVE working boot
# components (~/boot_genesys/boot.bif) and swaps in the AD4080 bitstream.
#
# DO NOT use projects/ad738x_fmc/genesys_zu5ev/boot_bin/*.bif -- that recipe uses
# the ~stock FSBL + omits dt.dtb and produces a non-booting image (ERR LED, no
# serial). See that dir's DO_NOT_USE_README.txt.
#
# Root cause history (2026-07-24): the Genesys ZU-5EV needs the Digilent-patched
# FSBL. The stock FSBL (594400/595032/594680, ~594K) bricks before serial. A
# working BOOT.BIN must ALSO include the u-boot device tree dt.dtb at load
# 0x00100000.
#
# FSBL/PMUFW CORRECTED 2026-08-03 -- THERE ARE TWO REQUIREMENTS, NOT ONE:
#   (a) Digilent-patched (~614K, not the ~594K stock)  -> else the board bricks
#   (b) generated from the AD4080 XSA                  -> else PL regs are broken
# This script used to point at fsbl.elf (614856, 2026-06-26) + pmufw.elf
# (503752), which are the AD7383-era pair. They satisfy (a) but NOT (b): the
# AD7383 psu_init never configures M_AXI_HPM0_LPD (LPD_SLCR_AFI_FS DW_SS2_SEL),
# leaving the PL bus in 128-bit mode against a 32-bit port, so ONLY 16-byte
# ALIGNED register offsets are reachable. That silently corrupts every PL
# peripheral's register map -- it is what killed 10G in v1.0.0, and it would
# make the clock monitor counter at 0x80050048 (NOT 16-byte aligned) unreadable.
# Use the AD4080 XSA pair, which is Digilent-patched AND has the right psu_init:
#   fsbl_ad4080.elf  614912  2026-07-26
#   pmufw_ad4080.elf 503788  2026-07-26
# Verified in v1.0.1: 10 Gb/s link, 2.71 Gbit/s, 22 h soak, PL regs correct.
#
# Usage (WSL):  bash make_boot.sh   ->  /tmp/BOOT_ad4080.BIN
set -e
source /opt/Xilinx/2025.1/Vitis/settings64.sh

BIT=/mnt/d/hdl/projects/ad4080_fmc_evb/genesys_zu5ev/ad4080_fmc_evb_genesys_zu5ev.runs/impl_1/system_top.bit
OUT=/tmp/BOOT_ad4080.BIN
FSBL=/home/scott/boot_genesys/fsbl_ad4080.elf
PMUFW=/home/scott/boot_genesys/pmufw_ad4080.elf

# Guard against silently reverting to the AD7383-era pair (see banner). Sizes
# are the AD4080-XSA Digilent-patched builds; ~594K would be stock (bricks),
# 614856/503752 would be the AD7383 pair (breaks PL register alignment).
for f in "$FSBL" "$PMUFW"; do
	[ -f "$f" ] || { echo "MISSING: $f"; exit 1; }
done
sz_fsbl=$(stat -c %s "$FSBL"); sz_pmu=$(stat -c %s "$PMUFW")
[ "$sz_fsbl" = "614912" ] || { echo "REFUSING: $FSBL is $sz_fsbl bytes, expected 614912 (AD4080 XSA, Digilent-patched)"; exit 1; }
[ "$sz_pmu"  = "503788" ] || { echo "REFUSING: $PMUFW is $sz_pmu bytes, expected 503788 (AD4080 XSA)"; exit 1; }
echo "fsbl/pmufw verified: AD4080 XSA pair"

cat > /tmp/boot_ad4080.bif <<EOF
the_ROM_image:
{
	[bootloader, destination_cpu=a53-0] $FSBL
	[pmufw_image] $PMUFW
	[destination_device=pl] $BIT
	[destination_cpu=a53-0, exception_level=el-3, trustzone] /home/scott/arm-trusted-firmware/build/zynqmp/release/bl31/bl31.elf
	[destination_cpu=a53-0, load=0x00100000] /home/scott/u-boot-xlnx/dts/dt.dtb
	[destination_cpu=a53-0, exception_level=el-2] /home/scott/u-boot-xlnx/u-boot.elf
}
EOF

bootgen -image /tmp/boot_ad4080.bif -arch zynqmp -o "$OUT" -w on
echo "built $OUT"
md5sum "$OUT"
# sanity: must list fsbl + bitstream + bl31 + dt.dtb + u-boot
bootgen -arch zynqmp -read "$OUT" 2>/dev/null | grep -E "IMAGE HEADER \("
