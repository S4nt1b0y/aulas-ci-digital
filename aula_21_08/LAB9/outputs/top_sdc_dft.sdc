# ####################################################################

#  Created by Genus(TM) Synthesis Solution 25.12-s067_1 on Fri Aug 21 18:51:52 -03 2026

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design top

create_clock -name "clk" -period 10.0 -waveform {0.0 5.0} [get_ports clk]
set_clock_transition 3.0 [get_clocks clk]
set_clock_gating_check -setup 0.0 
set_input_delay -clock [get_clocks clk] -add_delay -max 12.0 [get_ports rst]
set_input_delay -clock [get_clocks clk] -add_delay -max 12.0 [get_ports {cmd_in[6]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 12.0 [get_ports {cmd_in[5]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 12.0 [get_ports {cmd_in[4]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 12.0 [get_ports {cmd_in[3]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 12.0 [get_ports {cmd_in[2]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 12.0 [get_ports {cmd_in[1]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 12.0 [get_ports {cmd_in[0]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 12.0 [get_ports {din_1[7]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 12.0 [get_ports {din_1[6]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 12.0 [get_ports {din_1[5]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 12.0 [get_ports {din_1[4]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 12.0 [get_ports {din_1[3]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 12.0 [get_ports {din_1[2]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 12.0 [get_ports {din_1[1]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 12.0 [get_ports {din_1[0]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 12.0 [get_ports {din_2[7]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 12.0 [get_ports {din_2[6]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 12.0 [get_ports {din_2[5]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 12.0 [get_ports {din_2[4]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 12.0 [get_ports {din_2[3]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 12.0 [get_ports {din_2[2]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 12.0 [get_ports {din_2[1]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 12.0 [get_ports {din_2[0]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 12.0 [get_ports {din_3[7]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 12.0 [get_ports {din_3[6]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 12.0 [get_ports {din_3[5]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 12.0 [get_ports {din_3[4]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 12.0 [get_ports {din_3[3]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 12.0 [get_ports {din_3[2]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 12.0 [get_ports {din_3[1]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 12.0 [get_ports {din_3[0]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 15.0 [get_ports {dout_low[7]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 15.0 [get_ports {dout_low[6]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 15.0 [get_ports {dout_low[5]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 15.0 [get_ports {dout_low[4]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 15.0 [get_ports {dout_low[3]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 15.0 [get_ports {dout_low[2]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 15.0 [get_ports {dout_low[1]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 15.0 [get_ports {dout_low[0]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 15.0 [get_ports {dout_high[7]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 15.0 [get_ports {dout_high[6]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 15.0 [get_ports {dout_high[5]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 15.0 [get_ports {dout_high[4]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 15.0 [get_ports {dout_high[3]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 15.0 [get_ports {dout_high[2]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 15.0 [get_ports {dout_high[1]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 15.0 [get_ports {dout_high[0]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 15.0 [get_ports cpu_rdy]
set_output_delay -clock [get_clocks clk] -add_delay -max 15.0 [get_ports zero]
set_output_delay -clock [get_clocks clk] -add_delay -max 15.0 [get_ports error]
set_wire_load_mode "enclosed"
set_clock_uncertainty -setup 3.0 [get_ports clk]
set_clock_uncertainty -hold 3.0 [get_ports clk]
