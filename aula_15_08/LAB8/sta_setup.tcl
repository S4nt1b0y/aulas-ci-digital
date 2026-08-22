set DESIGN pattern_detector
set CORNER slow

set_db init_lib_search_path ../LAB7

if {$CORNER eq "slow"} {
    set LIB slow_vdd1v0_basicCells.lib
} elseif {$CORNER eq "fast"} {
    set LIB fast_vdd1v0_basicCells.lib
} else {
    error "CORNER deve ser slow ou fast"
}

set_db library $LIB

set NETLIST ./${DESIGN}_netlist.v
set SDC ./constraint.sdc

file mkdir ./reports

read_netlist $NETLIST
read_sdc $SDC
check_design -unresolved

report timing -lint > ./reports/${DESIGN}_lint_${CORNER}.rpt
report_timing -max_paths 10 > ./reports/${DESIGN}_setup_${CORNER}.rpt
report_timing_summary > ./reports/${DESIGN}_setup_summary_${CORNER}.rpt
exit
