create_clock -name clk -period 10 -waveform {0 5} [get_ports "clk"]
set_clock_transition -rise 3 [get_clocks "clk"]
set_clock_transition -fall 3 [get_clocks "clk"]
set_clock_uncertainty 3 [get_ports "clk"]
set_input_delay -max 12 [get_ports [all_inputs]] -clock [get_clocks "clk"]
set_output_delay -max 15 [get_ports [all_outputs]] -clock [get_clocks "clk"]



