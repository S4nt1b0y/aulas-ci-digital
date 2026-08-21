set_db init_lib_search_path ./LIB/
set_db init_hdl_search_path ./RTL/
read_libs slow_vdd1v0_basicCells.lib
read_hdl {top.v ALU.v control.v memory.v mux4.v mux4_registered.v register_bank.v}
elaborate 
read_sdc ./constraints_top_baseline.sdc

set_db dft_scan_style muxed_scan 
set_db dft_prefix dft_
define_shift_enable -name SE -active high -create_port SE
check_dft_rules

set_db syn_generic_effort medium
syn_generic
set_db syn_map_effort medium
syn_map
set_db syn_opt_effort medium
syn_opt

check_dft_rules 
set_db design:top .dft_min_number_of_scan_chains 1 
define_scan_chain -name top_chain -sdi scan_in -sdo scan_out -create_ports  

connect_scan_chains -auto_create_chains 
syn_opt -incremental

report_scan_chains 
write_dft_atpg -library ../LIB/slow_vdd1v0_basiccells.v
write_hdl > outputs/top_netlist_dft.v
write_sdc > outputs/top_sdc_dft.sdc
write_sdf -nonegchecks -edges check_edge -timescale ns -recrem split  -setuphold split > outputs/dft_delays.sdf
write_scandef > outputs/top_scanDEF.scandef

#################################
### Reports
#################################
report_timing > reports/report_timing.rpt
report_power  > reports/report_power.rpt
report_area   > reports/report_area.rpt
report_qor    > reports/report_qor.rpt
