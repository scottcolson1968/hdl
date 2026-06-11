# AD738X-FMC HDL Project — Digilent Genesys ZU-5EV carrier

Port of the [ad738x_fmc](https://analogdevicesinc.github.io/hdl/projects/ad738x_fmc/index.html)
project from the ZedBoard to the Digilent Genesys ZU-5EV (Zynq UltraScale+
XCZU5EV-SFVC784-1-E, FMC LPC connector). Not an officially supported ADI carrier.

## Prerequisites

- Vivado 2025.1 (matches the `hdl_2026_r1` branch this port is built on)
- Digilent board files (`digilentinc.com:gzu_5ev`), e.g. from
  https://github.com/Digilent/vivado-boards — `system_project.tcl` points
  `board.repoPaths` at `D:/digilent-vivado-boards/new/board_files`; override
  with the `GENESYS_ZU_BOARD_FILES` environment variable if located elsewhere.

## Building (WSL — primary flow)

ADI's supported flow is `make` with the Linux tools. On this machine Vivado/
Vitis 2025.1 are installed inside WSL2 Ubuntu (distro stored on D:), and the
HDL repo is reached via the /mnt/d mount:

```bash
source /opt/Xilinx/2025.1/Vivado/settings64.sh
cd /mnt/d/hdl/projects/ad738x_fmc/genesys_zu5ev
make    # NUM_OF_SDI=2 etc. as make variables if non-default
```

The resulting project is `ad738x_fmc_genesys_zu5ev.xpr` in this directory
(synthesized + implemented, bitstream included — allow ~30+ minutes). Open it
with the WSL Vivado GUI (WSLg): `vivado ad738x_fmc_genesys_zu5ev.xpr &`

`build_win.ps1` is kept as a fallback that replicates the make sequence with
a native Windows Vivado, should one ever be installed.

Build parameters (set as environment variables before building, same as the
ZedBoard project): `ALERT_SPI_N` (0/1), `NUM_OF_SDI` (1/2/4).

## FMC pin mapping (bank 65, VADJ)

| Signal   | FMC pin | LA net        | ZU-5EV pin |
|----------|---------|---------------|------------|
| spi_sclk | G6      | LA00_CC_P     | L7         |
| spi_cs   | G7      | LA00_CC_N     | L6         |
| spi_sdo  | H7      | LA02_P        | J6         |
| spi_sdia | D8      | LA01_CC_P     | H4         |
| spi_sdib | D9      | LA01_CC_N     | H3         |
| spi_sdic | H8      | LA02_N        | H6         |
| spi_sdid | G9      | LA03_P        | K4         |

## VADJ warning

The ZedBoard version of this project runs the FMC bank at 2.5 V (LVCMOS25).
The Genesys ZU FMC bank is an UltraScale+ HP bank (max 1.8 V); this port uses
LVCMOS18 and assumes VADJ = 1.8 V. The Genesys ZU platform MCU negotiates
VADJ from the mezzanine's FMC EEPROM (IPMI); verify that VADJ actually comes
up at 1.8 V with the EVAL-AD738x attached before trusting captured data
(AD7380 VIO minimum is 1.71 V, so 1.8 V logic is within spec).
