# LAB10 - Pattern detector constraints
# Valores em ns e pF. Analise solicitada: setup, corner Slow.

create_clock -name WClk -period 10 -waveform {0 5} [get_ports "WClk"]
create_clock -name RClk -period 12.5 -waveform {0 6.25} [get_ports "RClk"]

set_clock_transition 0.10 [get_clocks WClk]
set_clock_uncertainty -setup 0.20 [get_clocks WClk]

# Fonte de amostras: tCO,max 1.20 ns + interconexao 0.30 ns
set_input_delay -max 1.50 -clock [get_clocks WClk] [get_ports {Data_in[*] WriteEn_in Clear_in}]
set_input_transition 0.20 [get_ports {Data_in[*] WriteEn_in Clear_in}]

# Receptor de saida: tSU 1.00 ns + interconexao 0.30 ns; Cin 0.020 pF
set_output_delay -max 1.30 -clock [get_clocks WClk] [get_ports Full_out]
set_load -pin_load -max 0.020 [get_ports Full_out]

set_clock_transition 0.10 [get_clocks  RClk]
set_clock_uncertainty -setup 0.20 [get_clocks  RClk]

# Fonte de amostras: tCO,max 1.20 ns + interconexao 0.30 ns
set_input_delay -max 1.50 -clock [get_clocks  RClk] [get_ports {ReadEn_in Clear_in}]
set_input_transition 0.20 [get_ports {ReadEn_in Clear_in}]

# Receptor de saida: tSU 1.00 ns + interconexao 0.30 ns; Cin 0.020 pF
set_output_delay -max 1.30 -clock [get_clocks  RClk] [get_ports {Data_out[*] Empty_out}]
set_load -pin_load -max 0.020 [get_ports {Data_out[*] Empty_out}]

set_clock_groups -asynchronous -group {WClk} -group {RClk}
