# ####################################################################

#  Created by Genus(TM) Synthesis Solution 25.12-s067_1 on Fri Aug 07 21:41:36 -03 2026

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design x3_curto

create_clock -name "clk" -period 0.42 -waveform {0.0 0.21} [get_ports clk]
set_clock_gating_check -setup 0.0 
set_wire_load_mode "enclosed"
