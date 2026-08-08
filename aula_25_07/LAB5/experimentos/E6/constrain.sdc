# Clock
create_clock -name clk -period 1.28 -waveform {0 0.64} [get_ports "clk"]

# Output load
set_load 1 [get_ports {busy done result}]