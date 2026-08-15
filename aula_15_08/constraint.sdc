# Valores didaticos: tempo em ns e capacitancia em pF
set CLOCK_PERIOD 10.0
create_clock -name clk -period $CLOCK_PERIOD [get_ports clk]
set_clock_transition -rise 0.10 [get_clocks clk]
set_clock_transition -fall 0.10 [get_clocks clk]
set_clock_uncertainty 0.01 [get_clocks clk]
# Entradas de dados: exclui o clock
set DATA_IN [remove_from_collection [all_inputs] [get_ports clk]]
set_input_delay -max 0.10 -clock [get_clocks clk] $DATA_IN
set_input_transition 0.10 $DATA_IN
# Saidas: pequeno delay externo e carga minima
set_output_delay -max 0.10 -clock [get_clocks clk] [all_outputs]
set_load -max -pin_load 0.001 [all_outputs]