# LAB8 - Analises apos a sintese

## 3. Analises apos a sintese

As analises abaixo usam a netlist sintetizada `pattern_detector_netlist.v` e os reports ja gerados em `reports/`. O corner analisado e o Slow (`PVT_0P9V_125C`) e a busca de Fmax foi feita sem ressintetizar, alterando somente `CLOCK_PERIOD`.

## 4. Calculo dos delays maximos e SDC

Os delays de I/O foram obtidos somando o atraso do bloco externo com o atraso de interconexao:

| Interface | Calculo | Delay maximo |
|---|---:|---:|
| Fonte de amostras (`in_data`, `in_valid`, `out_ready`) | `tCO,max + interconexao = 1.20 + 0.30` | `1.50 ns` |
| ROM externa para o detector (`rom_data`) | `tCO,max + interconexao = 1.40 + 0.20` | `1.60 ns` |
| Saidas do detector (`out_data`, `out_valid`, `in_ready`) | `tSU + interconexao = 1.00 + 0.30` | `1.30 ns` |
| Endereco para a ROM externa (`rom_addr`) | `tSU + interconexao = 0.80 + 0.20` | `1.00 ns` |

SDC elaborado:

```tcl
# LAB8 - Pattern detector constraints
# Valores em ns e pF. Analise solicitada: setup, corner Slow.

set CLOCK_PERIOD 10.00

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
```

Observacao: para a busca de Fmax, o mesmo SDC foi mantido e somente `CLOCK_PERIOD` foi reduzido. O arquivo `constraint.sdc` atual esta com `CLOCK_PERIOD = 9.05 ns`, correspondente a ultima tentativa registrada.

## 5. Setup com T = 10 ns no corner Slow

O circuito atende setup em 100 MHz, pois o pior slack e positivo.

| Item | Valor |
|---|---:|
| Periodo | `10.00 ns` |
| Frequencia | `100 MHz` |
| WNS | `954.4 ps = 0.9544 ns` |
| TNS | `0.0 ps` |
| Startpoint | `rom_data[1]` |
| Endpoint | `mac_i_result_reg[34]/D` |
| Pior caminho | `rom_data[1] -> csa_tree_ADD_TC_OP_groupi... -> mac_i_result_reg[34]/D` |

No report de timing de 100 MHz, o Path 1 aparece como `MET (954 ps)`, com `Input Delay = 1600 ps`, `Data Path = 7151 ps` e `Slack = 954 ps`.

## 6. Classificacao do pior caminho

O pior caminho e `in2reg`, porque parte de uma entrada primaria (`rom_data[1]`) e termina no registrador interno `mac_i_result_reg[34]`.

Blocos logicos presentes:

- Entrada externa `rom_data[1]`.
- Logica combinacional da multiplicacao signed sintetizada.
- Arvore de soma/acumulacao `csa_tree_ADD_TC_OP_groupi`.
- Celulas de propagacao de carry/soma, principalmente `ADDFX1`, alem de inversores e portas logicas.
- Mux/logica de escrita do acumulador.
- Registrador `mac_i_result_reg[34]`.

## 7. Comparacao entre `in_data`, `rom_data`, `rom_addr` e `out_data`

Em 100 MHz, considerando a incerteza de clock de `0.20 ns`, o orcamento aproximado para a logica interna fica:

| Interface | Calculo | Orcamento |
|---|---:|---:|
| `in_data` | `10.00 - 1.50 - 0.20` | `8.30 ns` |
| `rom_data` | `10.00 - 1.60 - 0.20` | `8.20 ns` |
| `out_data` | `10.00 - 1.30 - 0.20` | `8.50 ns` |
| `rom_addr` | `10.00 - 1.00 - 0.20` | `8.80 ns` |

A interface que deixa menor orcamento para a logica interna e `rom_data`, pois tem o maior delay de entrada (`1.60 ns`). Isso tambem aparece no pior caminho de setup, que parte de `rom_data[1]`.

## 8. Reutilizacao de uma multiplicacao e um somador/acumulador

A arquitetura reutiliza uma unica MAC:

- Em `pattern_detector.v`, existe uma unica instancia `mac_i`.
- Em `mac_param.v`, existe uma unica multiplicacao combinacional: `assign product = a * b;`.
- O acumulador tambem e unico: `result <= result + product_ext;`.

A FSM controla essa reutilizacao no tempo:

- `STATE_ROM_WAIT`: coloca `rom_addr = 0` e ativa `mac_start`, limpando/iniciando a MAC.
- `STATE_MAC_RUN`: ativa `mac_valid` e acumula um produto por ciclo.
- Para `N=8`, a MAC executa 8 acumulacoes, uma para cada coeficiente/amostra.
- `STATE_CAPTURE`: copia o resultado final para `out_data`.
- `STATE_HOLD`: mantem `out_valid` ate o consumidor aceitar o resultado.

Assim, a correlacao nao usa 8 multiplicadores em paralelo; ela usa uma multiplicacao e um acumulador reaproveitados ao longo dos estados da FSM.

## 9. Latencia em simulacao e taxa maxima de amostras

Com `N=8` e `100 MHz`, a simulacao funcional do testbench passou:

```text
TESTE OK
```

Tambem foi feita uma simulacao com contador de ciclos entre a aceitacao da amostra que completa a janela e a primeira ativacao de `out_valid`:

```text
accept_cycle=15 out_valid_cycle=26 latency_cycles=11
```

A latencia medida e de 11 ciclos de clock:

1. borda de aceitacao da amostra;
2. ciclo seguinte em `STATE_ROM_WAIT`, para iniciar a MAC e alinhar a ROM sincrona;
3. 8 ciclos em `STATE_MAC_RUN`, um produto acumulado por ciclo;
4. 1 ciclo em `STATE_CAPTURE`, para capturar `mac_result`;
5. no ciclo seguinte a FSM entra em `STATE_HOLD` e `out_valid = 1`.

Logo:

```text
latencia = 11 ciclos = 11 * 10 ns = 110 ns
```

Com `out_ready = 1`, depois que a janela inicial ja esta cheia, uma segunda simulacao com `in_valid` continuamente ativo mediu 12 ciclos entre duas aceitacoes consecutivas:

```text
first_accept=8 second_accept=20 interval_cycles=12
```

Assim, a taxa maxima aceita pelo protocolo e:

```text
taxa maxima = 100 MHz / 12 = 8.33 MSamples/s
```

## 10. Busca de Fmax sem ressintese

Na tabela abaixo, os valores de WNS estao em ps. A coluna de frequencia foi corrigida para `F (MHz)`.

| Tent | T (ns) | F (MHz) | WNS in2reg (ps) | WNS reg2reg (ps) | WNS reg2out (ps) |
|---:|---:|---:|---:|---:|---:|
| 1 | 10.00 | 100.000 | 954.4 | 1338.7 | 7865.0 |
| 2 | 4.00 | 250.000 | -5045.6 | -4661.3 | 1865.0 |
| 3 | 6.00 | 166.667 | -3045.6 | -2661.3 | 3865.0 |
| 4 | 8.00 | 125.000 | -1045.6 | 661.3 | 5865.0 |
| 5 | 9.00 | 111.111 | -45.6 | 338.7 | 6865.0 |
| 6 | 9.20 | 108.696 | 154.4 | 538.6 | 7065.0 |
| 7 | 9.10 | 109.890 | 54.4 | 438.7 | 6965.0 |
| 8 | 9.05 | 110.497 | 4.4 | 388.7 | 6915.0 |

Pela ultima tentativa, em `T = 9.05 ns`, o WNS limitante e `4.4 ps`. Portanto:

```text
Tmin = 9.05 ns - 0.0044 ns = 9.0456 ns
Fmax = 1000 / 9.0456 = 110.55 MHz
```

Resultado:

```text
Tmin = 9.0456 ns | Fmax = 110.55 MHz | caminho/grupo limitante = in2reg
```

## 11. Caminho/grupo limitante na Fmax

Na Fmax, o grupo limitante continua sendo `in2reg`. O report da ultima tentativa (`T = 9.05 ns`) mostra:

| Grupo | WNS |
|---|---:|
| `in2reg` | `4.4 ps` |
| `reg2reg` | `388.7 ps` |
| `reg2out` | `6915.0 ps` |

Portanto, e o mesmo tipo de caminho observado em 100 MHz: a entrada `rom_data` atravessa a logica combinacional de multiplicacao/soma/acumulacao ate `mac_i_result_reg[34]`. Ao reduzir o periodo, todos os slacks diminuem quase linearmente, mas o `in2reg` ja era o menor em 100 MHz e permanece como limitante na Fmax.

## Evidencias usadas

- `constraint.sdc`: delays de I/O, transitions, loads, uncertainty e periodo usado na ultima busca.
- `reports/report_timing.rpt`: pior caminho em 100 MHz.
- `reports/pattern_detector_setup_slow.rpt`: pior caminho em `T = 9.05 ns`.
- `reports/pattern_detector_setup_summary_slow.rpt`: WNS/TNS por grupo em `T = 9.05 ns`.
- `mac_param.v`: unica multiplicacao e unico acumulador.
- `fsm.v`: estados de controle da reutilizacao da MAC.
- Simulacao RTL com `iverilog`/`vvp`: `TESTE OK`.
