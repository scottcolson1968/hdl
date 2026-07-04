# CDC exceptions for the open-MAC support blocks.
# xxv_shim block-lock enters a 2FF ASYNC_REG synchronizer from the PCS clock
# domain -- false path by design (was reported at -1.4ns without this).
set_false_path -to [get_pins -hierarchical -filter {NAME =~ "*/xxv_shim/inst/blk_sync_reg[0]/D"}]
