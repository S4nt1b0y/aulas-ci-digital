# ============================================================
# SÍNTESE DE REFERÊNCIA - MAC SEM DfT
# ============================================================

file mkdir reports/base

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
# Constraints
# ------------------------------------------------------------

read_sdc constrain_lab12.sdc

# ------------------------------------------------------------
# Esforços - iguais ao fluxo DFT
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
# Reports de referência
# ------------------------------------------------------------

report_gates  > reports/base/mac_base_gates.rpt
report_area   > reports/base/mac_base_area.rpt
report_timing > reports/base/mac_base_timing.rpt
report_power  > reports/base/mac_base_power.rpt
report_qor    > reports/base/mac_base_qor.rpt

exit