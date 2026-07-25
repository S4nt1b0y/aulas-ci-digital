# Cadence Genus(TM) Synthesis Solution, Version 25.12-s067_1, built Nov 17 2025 13:10:10

# Date: Fri Jul 24 20:05:01 2026
# Host: localhost.localdomain (x86_64 w/Linux 5.14.0-687.17.1.el9_8.x86_64) (8cores*16cpus*1physical cpu*AMD Ryzen 7 5700G with Radeon Graphics 512KB)
# OS:   Rocky Linux 9.8 (Blue Onyx)

read_libs { ../LIB/fast_vdd1v0_basicCells.lib ../LIB/slow_vdd1v0_basicCells.lib }
read_physical -lef { ../LEF/gsclib045_macro.lef ../LEF/gsclib045_tech.lef }
read_hdl "../RTL/counter.v"
check_design -unresolved
read_hdl ../RTL/counter.v
check_design -unresolved
elaborate
check_design -unresolved
read_sdc ../constraints/constraints_top.sdc
reset_design
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
