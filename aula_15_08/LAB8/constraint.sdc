# LAB8 - Pattern detector constraints
# Valores em ns e pF. Analise solicitada: setup, corner Slow.

set CLOCK_PERIOD 9.05

create_clock -name clk -period $CLOCK_PERIOD [get_ports clk]
set_clock_transition 0.10 [get_clocks clk]
set_clock_uncertainty -setup 0.20 [get_clocks clk]

# Fonte de amostras: tCO,max 1.20 ns + interconexao 0.30 ns
set_input_delay -max 1.50 -clock [get_clocks clk] [get_ports {in_data[*] in_valid out_ready}]
set_input_transition 0.20 [get_ports {in_data[*] in_valid out_ready}]

# Saida da ROM externa: tCO,max 1.40 ns + interconexao 0.20 ns
set_input_delay -max 1.60 -clock [get_clocks clk] [get_ports {rom_data[*]}]
set_input_transition 0.15 [get_ports {rom_data[*]}]

# Receptor de saida: tSU 1.00 ns + interconexao 0.30 ns; Cin 0.020 pF
set_output_delay -max 1.30 -clock [get_clocks clk] [get_ports {out_data[*] out_valid in_ready}]
set_load -pin_load -max 0.020 [get_ports {out_data[*] out_valid in_ready}]

# Entrada da ROM externa: tSU 0.80 ns + interconexao 0.20 ns; Cin 0.010 pF
set_output_delay -max 1.00 -clock [get_clocks clk] [get_ports {rom_addr[*]}]
set_load -pin_load -max 0.010 [get_ports {rom_addr[*]}]

# Reset assincrono, fora dos caminhos funcionais de setup.
set_false_path -from [get_ports rst_n]
