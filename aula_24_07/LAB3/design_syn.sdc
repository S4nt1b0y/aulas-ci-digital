# ####################################################################

#  Created by Genus(TM) Synthesis Solution 25.12-s067_1 on Sat Jul 25 12:02:37 -03 2026

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design x3_curto

create_clock -name "clk" -period 10.0 -waveform {0.0 5.0} [get_ports clk]
set_clock_transition -rise 0.2 [get_clocks clk]
set_clock_transition -fall 0.3 [get_clocks clk]
set_clock_gating_check -setup 0.0 
set_wire_load_mode "enclosed"
set_clock_uncertainty -setup 0.1 [get_clocks clk]
set_clock_uncertainty -hold 0.1 [get_clocks clk]
