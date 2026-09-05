file mkdir reports
file mkdir outputs

set_db init_lib_search_path ../aula_21_08/LAB9/LIB/
read_libs slow_vdd1v0_basicCells.lib
read_hdl {mac_param.v mac_lab9_top.v}
elaborate mac_lab9_top
check_design -unresolved
read_sdc constrain_lab9.sdc

set_db syn_generic_effort medium
set_db syn_map_effort medium
set_db syn_opt_effort medium

syn_generic
syn_map
syn_opt

write_hdl > outputs/mac_lab9_baseline_netlist.v
write_sdc > outputs/mac_lab9_baseline.sdc

report_timing > reports/report_timing_baseline.rpt
report_power  > reports/report_power_baseline.rpt
report_area   > reports/report_area_baseline.rpt
report_qor    > reports/report_qor_baseline.rpt
