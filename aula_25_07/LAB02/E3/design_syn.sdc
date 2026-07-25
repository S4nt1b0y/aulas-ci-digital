# ####################################################################

#  Created by Genus(TM) Synthesis Solution 25.12-s067_1 on Sat Jul 25 15:39:14 -03 2026

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design mac_param

create_clock -name "clk" -period 0.52 -waveform {0.0 0.26} [get_ports clk]
set_load -pin_load 1.0 [get_ports busy]
set_load -pin_load 1.0 [get_ports done]
set_load -pin_load 1.0 [get_ports {result[41]}]
set_load -pin_load 1.0 [get_ports {result[40]}]
set_load -pin_load 1.0 [get_ports {result[39]}]
set_load -pin_load 1.0 [get_ports {result[38]}]
set_load -pin_load 1.0 [get_ports {result[37]}]
set_load -pin_load 1.0 [get_ports {result[36]}]
set_load -pin_load 1.0 [get_ports {result[35]}]
set_load -pin_load 1.0 [get_ports {result[34]}]
set_load -pin_load 1.0 [get_ports {result[33]}]
set_load -pin_load 1.0 [get_ports {result[32]}]
set_load -pin_load 1.0 [get_ports {result[31]}]
set_load -pin_load 1.0 [get_ports {result[30]}]
set_load -pin_load 1.0 [get_ports {result[29]}]
set_load -pin_load 1.0 [get_ports {result[28]}]
set_load -pin_load 1.0 [get_ports {result[27]}]
set_load -pin_load 1.0 [get_ports {result[26]}]
set_load -pin_load 1.0 [get_ports {result[25]}]
set_load -pin_load 1.0 [get_ports {result[24]}]
set_load -pin_load 1.0 [get_ports {result[23]}]
set_load -pin_load 1.0 [get_ports {result[22]}]
set_load -pin_load 1.0 [get_ports {result[21]}]
set_load -pin_load 1.0 [get_ports {result[20]}]
set_load -pin_load 1.0 [get_ports {result[19]}]
set_load -pin_load 1.0 [get_ports {result[18]}]
set_load -pin_load 1.0 [get_ports {result[17]}]
set_load -pin_load 1.0 [get_ports {result[16]}]
set_load -pin_load 1.0 [get_ports {result[15]}]
set_load -pin_load 1.0 [get_ports {result[14]}]
set_load -pin_load 1.0 [get_ports {result[13]}]
set_load -pin_load 1.0 [get_ports {result[12]}]
set_load -pin_load 1.0 [get_ports {result[11]}]
set_load -pin_load 1.0 [get_ports {result[10]}]
set_load -pin_load 1.0 [get_ports {result[9]}]
set_load -pin_load 1.0 [get_ports {result[8]}]
set_load -pin_load 1.0 [get_ports {result[7]}]
set_load -pin_load 1.0 [get_ports {result[6]}]
set_load -pin_load 1.0 [get_ports {result[5]}]
set_load -pin_load 1.0 [get_ports {result[4]}]
set_load -pin_load 1.0 [get_ports {result[3]}]
set_load -pin_load 1.0 [get_ports {result[2]}]
set_load -pin_load 1.0 [get_ports {result[1]}]
set_load -pin_load 1.0 [get_ports {result[0]}]
set_clock_gating_check -setup 0.0 
set_wire_load_mode "enclosed"
