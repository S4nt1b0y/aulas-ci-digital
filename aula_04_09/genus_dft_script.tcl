file mkdir reports
file mkdir outputs

set_db init_lib_search_path ../aula_21_08/LAB9/LIB/
read_libs slow_vdd1v0_basicCells.lib
read_hdl {mac_param.v mac_lab9_top.v}
elaborate mac_lab9_top
check_design -unresolved
read_sdc constrain_lab9.sdc

set_db dft_scan_style muxed_scan
set_db dft_prefix dft_
define_shift_enable -name SE -active high -create_port SE
check_dft_rules

set_db syn_generic_effort medium
set_db syn_map_effort medium
set_db syn_opt_effort medium

syn_generic
syn_map
syn_opt

check_dft_rules
set_db design:mac_lab9_top .dft_min_number_of_scan_chains 1
define_scan_chain -name mac_chain -sdi scan_in -sdo scan_out -create_ports
connect_scan_chains -auto_create_chains
syn_opt -incremental

report_scan_chains > reports/report_scan_chains.rpt
write_dft_atpg -library ../aula_21_08/LAB9/LIB/slow_vdd1v0_basiccells.v

write_hdl > outputs/mac_lab9_scan_netlist.v
write_sdc > outputs/mac_lab9_scan.sdc
write_sdf -nonegchecks -edges check_edge -timescale ns -recrem split -setuphold split > outputs/mac_lab9_scan_delays.sdf
write_scandef > outputs/mac_lab9_scan.scandef

report_timing > reports/report_timing_scan.rpt
report_power  > reports/report_power_scan.rpt
report_area   > reports/report_area_scan.rpt
report_qor    > reports/report_qor_scan.rpt
