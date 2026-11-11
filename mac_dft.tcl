# ============================================================
# DFT / FULL SCAN - MAC PARAM
# ============================================================

file mkdir reports
file mkdir outputs

# ------------------------------------------------------------
# Biblioteca
# ------------------------------------------------------------

set_db init_lib_search_path ./aula_21_08/LAB9/LIB/

read_libs slow_vdd1v0_basicCells.lib

# ------------------------------------------------------------
# RTL
# ------------------------------------------------------------

read_hdl mac_param.v

elaborate mac_param

check_design -unresolved

# ------------------------------------------------------------
# Constraints funcionais
# ------------------------------------------------------------

read_sdc constrain_lab12.sdc

# ------------------------------------------------------------
# Configuração DFT
# ------------------------------------------------------------

set_db dft_scan_style muxed_scan
set_db dft_prefix dft_

define_shift_enable \
    -name SE \
    -active high \
    -create_port SE

# ------------------------------------------------------------
# DFT rule check - antes da síntese
# ------------------------------------------------------------

redirect reports/check_dft_rules_before.rpt {
    check_dft_rules
}

# ------------------------------------------------------------
# Esforços de síntese
# ------------------------------------------------------------

set_db syn_generic_effort medium
set_db syn_map_effort medium
set_db syn_opt_effort medium

# ------------------------------------------------------------
# Síntese
# ------------------------------------------------------------

syn_generic
syn_map
syn_opt

# ------------------------------------------------------------
# DFT rule check - após síntese/mapeamento
# ------------------------------------------------------------

redirect reports/check_dft_rules_after_map.rpt {
    check_dft_rules
}

# ------------------------------------------------------------
# Definição da scan chain
# ------------------------------------------------------------

set_db design:mac_param .dft_min_number_of_scan_chains 1

define_scan_chain \
    -name mac_chain \
    -sdi scan_in \
    -sdo scan_out \
    -create_ports

# ------------------------------------------------------------
# Conexão da scan chain
# ------------------------------------------------------------

connect_scan_chains -auto_create_chains

# ------------------------------------------------------------
# Otimização incremental
# ------------------------------------------------------------

syn_opt -incremental

# ------------------------------------------------------------
# Reports
# ------------------------------------------------------------

report_scan_chains > reports/report_scan_chains.rpt
report_gates       > reports/report_gates_scan.rpt
report_timing      > reports/report_timing_scan.rpt
report_area        > reports/report_area_scan.rpt
report_power       > reports/report_power_scan.rpt
report_qor         > reports/report_qor_scan.rpt

# ------------------------------------------------------------
# Arquivos de saída DFT
# ------------------------------------------------------------

write_hdl > outputs/mac_param_scan_netlist.v

write_sdc > outputs/mac_param_scan.sdc

write_sdf \
    -nonegchecks \
    -edges check_edge \
    -timescale ns \
    -recrem split \
    -setuphold split \
    > outputs/mac_param_scan_delays.sdf

write_scandef > outputs/mac_param_scan.scandef

exit