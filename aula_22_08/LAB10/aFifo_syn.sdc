# ####################################################################

#  Created by Genus(TM) Synthesis Solution 25.12-s067_1 on Sat Aug 22 16:04:22 -03 2026

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design aFifo

create_clock -name "WClk" -period 10.0 -waveform {0.0 5.0} [get_ports WClk]
create_clock -name "RClk" -period 12.5 -waveform {0.0 6.25} [get_ports RClk]
set_clock_transition 0.1 [get_clocks WClk]
set_clock_transition 0.1 [get_clocks RClk]
set_load -pin_load -max 0.02 [get_ports {Data_out[7]}]
set_load -pin_load -max 0.02 [get_ports {Data_out[6]}]
set_load -pin_load -max 0.02 [get_ports {Data_out[5]}]
set_load -pin_load -max 0.02 [get_ports {Data_out[4]}]
set_load -pin_load -max 0.02 [get_ports {Data_out[3]}]
set_load -pin_load -max 0.02 [get_ports {Data_out[2]}]
set_load -pin_load -max 0.02 [get_ports {Data_out[1]}]
set_load -pin_load -max 0.02 [get_ports {Data_out[0]}]
set_load -pin_load -max 0.02 [get_ports Empty_out]
set_load -pin_load -max 0.02 [get_ports Full_out]
set_clock_groups -name "clock_groups_WClk_to_RClk" -asynchronous -group [get_clocks WClk] -group [get_clocks RClk]
set_clock_gating_check -setup 0.0 
set_input_delay -clock [get_clocks WClk] -add_delay -max 1.5 [get_ports {Data_in[7]}]
set_input_delay -clock [get_clocks WClk] -add_delay -max 1.5 [get_ports {Data_in[6]}]
set_input_delay -clock [get_clocks WClk] -add_delay -max 1.5 [get_ports {Data_in[5]}]
set_input_delay -clock [get_clocks WClk] -add_delay -max 1.5 [get_ports {Data_in[4]}]
set_input_delay -clock [get_clocks WClk] -add_delay -max 1.5 [get_ports {Data_in[3]}]
set_input_delay -clock [get_clocks WClk] -add_delay -max 1.5 [get_ports {Data_in[2]}]
set_input_delay -clock [get_clocks WClk] -add_delay -max 1.5 [get_ports {Data_in[1]}]
set_input_delay -clock [get_clocks WClk] -add_delay -max 1.5 [get_ports {Data_in[0]}]
set_input_delay -clock [get_clocks WClk] -add_delay -max 1.5 [get_ports WriteEn_in]
set_output_delay -clock [get_clocks WClk] -add_delay -max 1.3 [get_ports Full_out]
set_input_delay -clock [get_clocks RClk] -add_delay -max 1.5 [get_ports ReadEn_in]
set_input_delay -clock [get_clocks RClk] -add_delay -max 1.5 [get_ports Clear_in]
set_output_delay -clock [get_clocks RClk] -add_delay -max 1.3 [get_ports {Data_out[7]}]
set_output_delay -clock [get_clocks RClk] -add_delay -max 1.3 [get_ports {Data_out[6]}]
set_output_delay -clock [get_clocks RClk] -add_delay -max 1.3 [get_ports {Data_out[5]}]
set_output_delay -clock [get_clocks RClk] -add_delay -max 1.3 [get_ports {Data_out[4]}]
set_output_delay -clock [get_clocks RClk] -add_delay -max 1.3 [get_ports {Data_out[3]}]
set_output_delay -clock [get_clocks RClk] -add_delay -max 1.3 [get_ports {Data_out[2]}]
set_output_delay -clock [get_clocks RClk] -add_delay -max 1.3 [get_ports {Data_out[1]}]
set_output_delay -clock [get_clocks RClk] -add_delay -max 1.3 [get_ports {Data_out[0]}]
set_output_delay -clock [get_clocks RClk] -add_delay -max 1.3 [get_ports Empty_out]
set_input_transition 0.2 [get_ports ReadEn_in]
set_input_transition 0.2 [get_ports {Data_in[7]}]
set_input_transition 0.2 [get_ports {Data_in[6]}]
set_input_transition 0.2 [get_ports {Data_in[5]}]
set_input_transition 0.2 [get_ports {Data_in[4]}]
set_input_transition 0.2 [get_ports {Data_in[3]}]
set_input_transition 0.2 [get_ports {Data_in[2]}]
set_input_transition 0.2 [get_ports {Data_in[1]}]
set_input_transition 0.2 [get_ports {Data_in[0]}]
set_input_transition 0.2 [get_ports WriteEn_in]
set_input_transition 0.2 [get_ports Clear_in]
set_wire_load_mode "enclosed"
set_clock_uncertainty -setup 0.2 [get_clocks WClk]
set_clock_uncertainty -setup 0.2 [get_clocks RClk]
