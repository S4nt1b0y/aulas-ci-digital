# Clock
create_clock -name clk -period 0.84 -waveform {0 0.42} [get_ports "clk"]

# Output load
set_load 1 [get_ports {busy done result}]