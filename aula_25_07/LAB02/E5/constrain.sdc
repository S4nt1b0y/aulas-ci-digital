# Clock
create_clock -name clk -period 0.64 -waveform {0 0.32} [get_ports "clk"]

# Output load
set_load 1 [get_ports {busy done result}]