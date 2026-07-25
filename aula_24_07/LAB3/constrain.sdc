create_clock -name clk -period 10 -waveform {0 5} [get_ports "clk"]
set_clock_transition -rise 0.2 [get_clocks "clk"]
set_clock_transition -fall 0.3 [get_clocks "clk"]
set_clock_uncertainty 0.1 [get_clocks "clk"]
