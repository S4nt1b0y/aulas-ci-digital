# Clock
create_clock -name clk -period 1.04 -waveform {0 0.52} [get_ports "clk"]

# Output load
set_load 1 [get_ports {busy done result}]