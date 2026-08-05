# CDC exceptions for the open-MAC support blocks.
# xxv_shim block-lock enters a 2FF ASYNC_REG synchronizer from the PCS clock
# domain -- false path by design (was reported at -1.4ns without this).
set_false_path -to [get_pins -hierarchical -filter {NAME =~ "*/xxv_shim/inst/blk_sync_reg[0]/D"}]

# cfg_tx_enable / cfg_rx_enable cross the OTHER way: from the xxv_shim register
# block (clk_pl_0) into the open_mac 2FF ASYNC_REG synchronizers (txen_sync /
# rxen_sync, clocked by tx_clk / rx_clk). False path by design -- without this
# they are timed with a ~0.4ns inter-clock window and report ~-0.85ns setup.
set_false_path -to [get_pins -hierarchical -filter {NAME =~ "*/open_mac/inst/txen_sync_reg[0]/D"}]
set_false_path -to [get_pins -hierarchical -filter {NAME =~ "*/open_mac/inst/rxen_sync_reg[0]/D"}]
