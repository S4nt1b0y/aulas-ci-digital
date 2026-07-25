read_libs { ../LIB/fast_vdd1v0_basicCells.lib ../LIB/slow_vdd1v0_basicCells.lib }
read_hdl "../RTL/counter.v"
elaborate
check_design -unresolved
read_sdc ../constraints/constraints_top.sdc
set_db / .syn_generic_effort medium
set_db / .syn_map_effort medium
set_db / .syn_opt_effort medium
syn_generic
syn_map
syn_opt
write_db counter -to_file design.db
write_hdl > design_syn.v
write_sdc > design_syn.sdc