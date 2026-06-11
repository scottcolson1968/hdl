###############################################################################
## Copyright (C) 2019-2023 Analog Devices, Inc. All rights reserved.
###
### In this HDL repository, there are many different and unique modules, consisting
### of various HDL (Verilog or VHDL) components. The individual modules are
### developed independently, and may be accompanied by separate and unique license
### terms.
###
### The user should read each of these license terms, and understand the
### freedoms and responsibilities that he or she has by using this source/core.
###
### This core is distributed in the hope that it will be useful, but WITHOUT ANY
### WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
### A PARTICULAR PURPOSE.
###
### Redistribution and use of source or resulting binaries, with or without modification
### of this file, are permitted under one of the following two license terms:
###
###   1. The GNU General Public License version 2 as published by the
###      Free Software Foundation, which can be found in the top level directory
###      of this repository (LICENSE_GPL2), and also online at:
###      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
###
### OR
###
###   2. An ADI specific BSD license, which can be found in the top level directory
###      of this repository (LICENSE_ADIBSD), and also on-line at:
###      https://github.com/analogdevicesinc/hdl/blob/main/LICENSE_ADIBSD
###      This will allow to generate bit files and not release the source code,
###      as long as it attaches to an ADI device.
###
### ***************************************************************************
### ***************************************************************************
###############################################################################

source $ad_hdl_dir/projects/scripts/adi_pd.tcl
source $ad_hdl_dir/projects/common/a10soc/a10soc_system_qsys.tcl

# Instances and instance parameters

set_instance_parameter_value sys_hps {CLK_EMACB_SOURCE} {1}
set_instance_parameter_value sys_hps {CLK_EMAC_PTP_SOURCE} {1}
set_instance_parameter_value sys_hps {EMAC_PTP_REF_CLK} {100}
set_instance_parameter_value sys_hps {EMAC1_CLK} {250}
set_instance_parameter_value sys_hps {EMAC1_Mode} {RGMII_with_MDIO}
set_instance_parameter_value sys_hps {EMAC1_PTP} {0}
set_instance_parameter_value sys_hps {EMAC1_PinMuxing} {FPGA}
set_instance_parameter_value sys_hps {EMAC1_SWITCH_Enable} {0}
set_instance_parameter_value sys_hps {EMAC2_CLK} {250}
set_instance_parameter_value sys_hps {EMAC2_Mode} {RGMII_with_MDIO}
set_instance_parameter_value sys_hps {EMAC2_PTP} {0}
set_instance_parameter_value sys_hps {EMAC2_PinMuxing} {FPGA}
set_instance_parameter_value sys_hps {EMAC2_SWITCH_Enable} {0}
set_instance_parameter_value sys_hps {FPGA_PERIPHERAL_OUTPUT_CLOCK_FREQ_EMAC1_GTX_CLK} {125}
set_instance_parameter_value sys_hps {FPGA_PERIPHERAL_OUTPUT_CLOCK_FREQ_EMAC1_MD_CLK} {2.5}
set_instance_parameter_value sys_hps {FPGA_PERIPHERAL_OUTPUT_CLOCK_FREQ_EMAC2_GTX_CLK} {125}
set_instance_parameter_value sys_hps {FPGA_PERIPHERAL_OUTPUT_CLOCK_FREQ_EMAC2_MD_CLK} {2.5}
set_instance_parameter_value sys_hps {FPGA_PERIPHERAL_OUTPUT_CLOCK_FREQ_I2C0_CLK} {100}
set_instance_parameter_value sys_hps {FPGA_PERIPHERAL_OUTPUT_CLOCK_FREQ_I2C1_CLK} {100}
set_instance_parameter_value sys_hps {FPGA_PERIPHERAL_OUTPUT_CLOCK_FREQ_I2CEMAC1_CLK} {100}
set_instance_parameter_value sys_hps {FPGA_PERIPHERAL_OUTPUT_CLOCK_FREQ_I2CEMAC2_CLK} {100}
set_instance_parameter_value sys_hps {FPGA_PERIPHERAL_OUTPUT_CLOCK_FREQ_QSPI_SCLK_OUT} {100}
set_instance_parameter_value sys_hps {FPGA_PERIPHERAL_OUTPUT_CLOCK_FREQ_SDMMC_CCLK} {100}
set_instance_parameter_value sys_hps {FPGA_PERIPHERAL_OUTPUT_CLOCK_FREQ_SPIM0_SCLK_OUT} {100}
set_instance_parameter_value sys_hps {FPGA_PERIPHERAL_OUTPUT_CLOCK_FREQ_SPIM1_SCLK_OUT} {100}


# exported interfaces
add_interface sys_hps_emac1 conduit end
set_interface_property sys_hps_emac1 EXPORT_OF sys_hps.emac1
add_interface sys_hps_emac1_md_clk clock source
set_interface_property sys_hps_emac1_md_clk EXPORT_OF sys_hps.emac1_md_clk
add_interface sys_hps_emac1_rx_clk_in clock sink
set_interface_property sys_hps_emac1_rx_clk_in EXPORT_OF sys_hps.emac1_rx_clk_in
add_interface sys_hps_emac1_tx_clk_in clock sink
set_interface_property sys_hps_emac1_tx_clk_in EXPORT_OF sys_hps.emac1_tx_clk_in
add_interface sys_hps_emac2 conduit end
set_interface_property sys_hps_emac2 EXPORT_OF sys_hps.emac2
add_interface sys_hps_emac2_md_clk clock source
set_interface_property sys_hps_emac2_md_clk EXPORT_OF sys_hps.emac2_md_clk
add_interface sys_hps_emac2_rx_clk_in clock sink
set_interface_property sys_hps_emac2_rx_clk_in EXPORT_OF sys_hps.emac2_rx_clk_in
add_interface sys_hps_emac2_tx_clk_in clock sink
set_interface_property sys_hps_emac2_tx_clk_in EXPORT_OF sys_hps.emac2_tx_clk_in

# internal connections
add_connection sys_clk.clk sys_hps.emac_ptp_ref_clock

#system ID
set_instance_parameter_value axi_sysid_0 {ROM_ADDR_BITS} {9}
set_instance_parameter_value rom_sys_0 {PATH_TO_FILE} "$mem_init_sys_file_path/mem_init_sys.txt"
set_instance_parameter_value rom_sys_0 {ROM_ADDR_BITS} {9}

sysid_gen_sys_init_file "MII"
