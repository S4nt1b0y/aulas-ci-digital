
# XM-Sim Command File
# TOOL:	xmsim(64)	25.03-s010
#

set tcl_prompt1 {puts -nonewline "xcelium> "}
set tcl_prompt2 {puts -nonewline "> "}
set vlog_format %h
set vhdl_format %v
set real_precision 6
set display_unit auto
set time_unit module
set heap_garbage_size -200
set heap_garbage_time 0
set assert_report_level note
set assert_stop_level error
set autoscope yes
set assert_1164_warnings yes
set pack_assert_off {}
set severity_pack_assert_off {note warning}
set assert_output_stop_level failed
set tcl_debug_level 0
set relax_path_name 1
set vhdl_vcdmap XX01ZX01X
set intovf_severity_level ERROR
set probe_screen_format 0
set rangecnst_severity_level ERROR
set textio_severity_level ERROR
set vital_timing_checks_on 1
set vlog_code_show_force 0
set assert_count_attempts 1
set tcl_all64 false
set tcl_runerror_exit false
set assert_report_incompletes 0
set show_force 1
set force_reset_by_reinvoke 0
set tcl_relaxed_literal 0
set probe_exclude_patterns {}
set probe_packed_limit 4k
set probe_unpacked_limit 16k
set assert_internal_msg no
set svseed 1
set assert_reporting_mode 0
set vcd_compact_mode 0
set vhdl_forgen_loopindex_enum_pos 0
set xmreplay_dc_debug 0
set tcl_runcmd_interrupt next_command
set tcl_sigval_prefix {#}
set gate_loop_warn_size 1
alias . run
alias indago verisium
alias quit exit
database -open -shm -into waves.shm waves -default
probe -create -database waves alu_8bit_tb.dut.A alu_8bit_tb.dut.B alu_8bit_tb.dut.C alu_8bit_tb.dut.C4 alu_8bit_tb.dut.G0 alu_8bit_tb.dut.G1 alu_8bit_tb.dut.N alu_8bit_tb.dut.P0 alu_8bit_tb.dut.P1 alu_8bit_tb.dut.V alu_8bit_tb.dut.Z alu_8bit_tb.dut.carry_in alu_8bit_tb.dut.generated_out alu_8bit_tb.dut.propagated_out alu_8bit_tb.dut.result_high alu_8bit_tb.dut.result_low alu_8bit_tb.dut.resultado alu_8bit_tb.dut.seletor
probe -create -database waves alu_8bit_tb.dut.ula_higher.A alu_8bit_tb.dut.ula_higher.B alu_8bit_tb.dut.ula_higher.C alu_8bit_tb.dut.ula_higher.N alu_8bit_tb.dut.ula_higher.V alu_8bit_tb.dut.ula_higher.Z alu_8bit_tb.dut.ula_higher.carry_in alu_8bit_tb.dut.ula_higher.carry_out_somador_cla alu_8bit_tb.dut.ula_higher.carry_out_subtrator_cla alu_8bit_tb.dut.ula_higher.generated_out alu_8bit_tb.dut.ula_higher.generated_sub alu_8bit_tb.dut.ula_higher.generated_sum alu_8bit_tb.dut.ula_higher.propagated_out alu_8bit_tb.dut.ula_higher.propagated_sub alu_8bit_tb.dut.ula_higher.propagated_sum alu_8bit_tb.dut.ula_higher.result_somador_cla alu_8bit_tb.dut.ula_higher.result_subtrator_cla alu_8bit_tb.dut.ula_higher.resultado alu_8bit_tb.dut.ula_higher.seletor alu_8bit_tb.dut.ula_lower.A alu_8bit_tb.dut.ula_lower.B alu_8bit_tb.dut.ula_lower.C alu_8bit_tb.dut.ula_lower.N alu_8bit_tb.dut.ula_lower.V alu_8bit_tb.dut.ula_lower.Z alu_8bit_tb.dut.ula_lower.carry_in alu_8bit_tb.dut.ula_lower.carry_out_somador_cla alu_8bit_tb.dut.ula_lower.carry_out_subtrator_cla alu_8bit_tb.dut.ula_lower.generated_out alu_8bit_tb.dut.ula_lower.generated_sub alu_8bit_tb.dut.ula_lower.generated_sum alu_8bit_tb.dut.ula_lower.propagated_out alu_8bit_tb.dut.ula_lower.propagated_sub alu_8bit_tb.dut.ula_lower.propagated_sum alu_8bit_tb.dut.ula_lower.result_somador_cla alu_8bit_tb.dut.ula_lower.result_subtrator_cla alu_8bit_tb.dut.ula_lower.resultado alu_8bit_tb.dut.ula_lower.seletor

simvision -input /home/cidigital/projects/aula_(28_e_29)_march/lab9/.simvision/22533_cidigital__autosave.tcl.svcf
