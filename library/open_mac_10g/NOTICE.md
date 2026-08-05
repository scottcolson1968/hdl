# open_mac_10g — third-party notice

This IP is a Vivado-packaged wrapper around the 10G Ethernet MAC from
**verilog-ethernet** by **Alex Forencich**, redistributed under the **MIT
licence**.

## Third-party files (MIT, © Alex Forencich)

Each retains its full copyright and permission notice in the file header; do not
strip them.

| file | copyright |
|---|---|
| `src/axis_fifo.v` | 2013-2023 |
| `src/axis_xgmii_rx_64.v` | 2015-2017 |
| `src/axis_xgmii_tx_64.v` | 2015-2017 |
| `src/eth_mac_10g.v` | 2015-2023 |
| `src/lfsr.v` | 2016-2023 |
| `src/mac_ctrl_rx.v` | 2023 |
| `src/mac_ctrl_tx.v` | 2023 |
| `src/mac_pause_ctrl_rx.v` | 2023 |
| `src/mac_pause_ctrl_tx.v` | 2023 |

Upstream: https://github.com/alexforencich/verilog-ethernet

## Local files

`src/open_mac_10g.v` is the Wildcat wrapper that adapts the above to the ADI
project structure. Sibling IPs `library/tx_csum_open` (open TX checksum offload)
and `library/xxv_shim` are also local.

These are **© 2026 Spectral Dynamics, MIT** (`SPDX-License-Identifier: MIT`),
chosen to match the verilog-ethernet code they wrap so the whole IP is uniformly
licensed. The same header is on the byte-identical copies under
`projects/ad4080_fmc_evb/genesys_zu5ev/cso_open/hdl/`, including the
`tb_tx_csum_open.v` testbench.

## Why this exists

The Xilinx 2022.1 checksum-offload IP is IEEE-1735 encrypted and will not
decrypt under Vivado 2025.1, and the eval XXV MAC carries a time-limited licence
that expires the link ~12.5 h after configuration. This open MAC plus
`tx_csum_open` replaces both, with no licence and no timebomb.

## Build note

The headless build consumes these from `$ad_hdl_dir/library`, because
`adi_project_create`'s `update_ip_catalog` must register them *before* it builds
the block design. `projects/ad4080_fmc_evb/genesys_zu5ev/cso_open/iprepo/` holds
a byte-identical copy used by the GUI build flow; it is deliberately not tracked
to avoid duplicating the third-party sources in the repository.
