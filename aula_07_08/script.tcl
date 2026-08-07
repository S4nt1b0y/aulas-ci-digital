read_libs {./slow_vdd1v0_basicCells.lib }
read_hdl "./mac_param.v"
elaborate
check_design -unresolved
read_sdc ./constrain.sdc
set_db / .syn_generic_effort medium
set_db / .syn_map_effort medium
set_db / .syn_opt_effort medium
syn_generic
syn_map
syn_opt
write_db mac_param -to_file design.db
write_hdl > design_syn.v
write_sdc > design_syn.sdc

report_timing > reports/report_timing.rpt
report_power > reports/report_power.rpt
report_area > reports/report_area.rpt
report_qor > reports/report_qor.rpt

write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge -setuphold split > outputs/delays.sdf