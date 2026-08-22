read_libs {../LAB7/slow_vdd1v0_basicCells.lib}

read_hdl "./mac_param.v"
read_hdl "./buffer.v"
read_hdl "./fsm.v"
read_hdl "./pattern_detector.v"
elaborate pattern_detector
check_design -unresolved

read_sdc "./constraint.sdc"

set_db / .syn_generic_effort medium
set_db / .syn_map_effort medium
set_db / .syn_opt_effort medium

syn_generic
syn_map
syn_opt

file mkdir reports
file mkdir outputs

write_db pattern_detector -to_file design.db
write_hdl > pattern_detector_netlist.v
write_sdc > pattern_detector_syn.sdc

report_timing > reports/report_timing.rpt
report_power > reports/report_power.rpt
report_area > reports/report_area.rpt
report_qor > reports/report_qor.rpt

write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge -setuphold split > outputs/delays.sdf
exit
