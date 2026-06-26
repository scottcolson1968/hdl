#!/usr/bin/env bash
# Assemble the 16ch gzu_5ev BOOT.BIN from the proven bitstream (in our tree) +
# the matched May-2025 boot components, mirroring c:\share\zynq.bif exactly.
set -eo pipefail
for s in /opt/Xilinx/2025.1/Vitis/settings64.sh /opt/Xilinx/2025.1/Vivado/settings64.sh; do
  [ -f "$s" ] && source "$s" && break
done
command -v bootgen >/dev/null || { echo "ERROR: no bootgen"; exit 1; }
OUT=$HOME/boot_gzu; mkdir -p "$OUT"
B=/mnt/c/share/ad738x_fmc/gzu_5ev/ALERTSPIN0_NUMOFSDI4/ad738x_gzu6
FSBL=$B/ad738x/zynqmp_fsbl/fsbl_a53.elf
PMUFW=$B/ad738x/zynqmp_pmufw/pmufw.elf
BIT=/mnt/d/hdl/projects/ad738x_fmc/gzu_5ev/ALERTSPIN0_NUMOFSDI4/ad738x_fmc_gzu_5ev.runs/impl_1/system_top.bit
BL31=/mnt/c/share/bl31.elf
UBOOT=/mnt/c/share/u-boot.elf
DTB=$B/devicetree/genesys-zu.dtb
IMAGE=/mnt/c/share/Image.ub
for f in "$FSBL" "$PMUFW" "$BIT" "$BL31" "$UBOOT" "$DTB" "$IMAGE"; do
  [ -f "$f" ] || { echo "MISSING: $f"; exit 1; }
done
cat > "$OUT/zynq_gzu.bif" <<BIF
the_ROM_image:
{
	[bootloader, destination_cpu = a53-0]$FSBL
	[pmufw_image]$PMUFW
	[destination_device = pl]$BIT
	[destination_cpu = a53-0, exception_level = el-3, trustzone]$BL31
	[destination_cpu = a53-0, exception_level = el-2]$UBOOT
	[load = 0x2a00000, destination_cpu = a53-0]$DTB
	[load = 0x3000000, destination_cpu = a53-0]$IMAGE
}
BIF
bootgen -arch zynqmp -image "$OUT/zynq_gzu.bif" -o "$OUT/BOOT.BIN" -w on
echo "=== built ==="; ls -la "$OUT/BOOT.BIN"; md5sum "$OUT/BOOT.BIN"
echo "=== bitstream packaged (should = proven 96b172d9) ==="; md5sum "$BIT"
