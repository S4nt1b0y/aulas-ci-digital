# ####################################################################

#  Created by Genus(TM) Synthesis Solution 25.12-s067_1 on Sat Aug 15 09:26:06 -03 2026

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design x3_curto

create_clock -name "clk" -period 10.0 -waveform {0.0 5.0} [get_ports clk]
set_clock_transition 0.1 [get_clocks clk]
set_load -pin_load -max 0.001 [get_ports {XPower[7]}]
set_load -pin_load -max 0.001 [get_ports {XPower[6]}]
set_load -pin_load -max 0.001 [get_ports {XPower[5]}]
set_load -pin_load -max 0.001 [get_ports {XPower[4]}]
set_load -pin_load -max 0.001 [get_ports {XPower[3]}]
set_load -pin_load -max 0.001 [get_ports {XPower[2]}]
set_load -pin_load -max 0.001 [get_ports {XPower[1]}]
set_load -pin_load -max 0.001 [get_ports {XPower[0]}]
set_clock_gating_check -setup 0.0 
set_input_delay -clock [get_clocks clk] -add_delay -max 0.1 [get_ports {X[7]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 0.1 [get_ports {X[6]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 0.1 [get_ports {X[5]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 0.1 [get_ports {X[4]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 0.1 [get_ports {X[3]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 0.1 [get_ports {X[2]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 0.1 [get_ports {X[1]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 0.1 [get_ports {X[0]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 0.1 [get_ports {XPower[7]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 0.1 [get_ports {XPower[6]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 0.1 [get_ports {XPower[5]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 0.1 [get_ports {XPower[4]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 0.1 [get_ports {XPower[3]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 0.1 [get_ports {XPower[2]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 0.1 [get_ports {XPower[1]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 0.1 [get_ports {XPower[0]}]
set_input_transition 0.1 [get_ports {X[7]}]
set_input_transition 0.1 [get_ports {X[6]}]
set_input_transition 0.1 [get_ports {X[5]}]
set_input_transition 0.1 [get_ports {X[4]}]
set_input_transition 0.1 [get_ports {X[3]}]
set_input_transition 0.1 [get_ports {X[2]}]
set_input_transition 0.1 [get_ports {X[1]}]
set_input_transition 0.1 [get_ports {X[0]}]
set_wire_load_mode "enclosed"
set_clock_uncertainty -setup 0.01 [get_clocks clk]
set_clock_uncertainty -hold 0.01 [get_clocks clk]
