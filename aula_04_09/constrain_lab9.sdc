create_clock -name clk -period 2.000 -waveform {0.000 1.000} [get_ports clk]

set_input_delay 0.200 -clock clk [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay 0.200 -clock clk [all_outputs]
set_load 1 [all_outputs]
