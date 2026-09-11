# Relatório Lab 12 - Síntese e Análise de Full Scan na MAC

## 1. Objetivo

Este relatório apresenta a síntese tecnológica da unidade MAC unsigned com inserção de full scan no Cadence Genus. A análise compara a versão de referência sem DfT com a versão com DfT, usando a mesma MAC, biblioteca, constraints e esforços de síntese.

O foco é medir:

- Quantos flip-flops foram inseridos em scan;
- Número e comprimento das scan chains;
- Overhead de área;
- Impacto de timing;
- Tempo de shift usando a chain real reportada pelo Genus;
- Evidências na netlist DFT e no ScanDEF.

## 2. Arquivos Usados

| Tipo | Arquivo |
|---|---|
| RTL funcional | `mac_param.v` |
| Top parametrizado para o lab | `mac_lab9_top.v` |
| SDC funcional | `constrain_lab9.sdc` |
| Script sem DfT | `genus_baseline_script.tcl` |
| Script com DfT | `genus_dft_script.tcl` |
| Área sem DfT | `reports/report_area_baseline.rpt` |
| Timing sem DfT | `reports/report_timing_baseline.rpt` |
| Área com DfT | `reports/report_area_scan.rpt` |
| Timing com DfT | `reports/report_timing_scan.rpt` |
| Scan chains | `reports/report_scan_chains.rpt` |
| Netlist DFT | `outputs/mac_lab9_scan_netlist.v` |
| ScanDEF | `outputs/mac_lab9_scan.scandef` |
| Log DFT | `genus.log1` |

Observação: o script atual não gerou arquivos `report_gates`. Por isso, as métricas de flip-flops foram extraídas de `check_dft_rules`, `report_scan_chains` e da netlist mapeada.

## 3. Configuração de DfT

A configuração aplicada no script DFT foi:

```tcl
set_db dft_scan_style muxed_scan
set_db dft_prefix dft_
define_shift_enable -name SE -active high -create_port SE
set_db design:mac_lab9_top .dft_min_number_of_scan_chains 1
define_scan_chain -name mac_chain -sdi scan_in -sdo scan_out -create_ports
connect_scan_chains -auto_create_chains
```

O estilo usado foi `muxed_scan`. O Genus criou a porta `SE` como shift enable ativo em nível alto e as portas seriais `scan_in` e `scan_out`.

## 4. Check DFT Rules

### 4.1 Antes do mapeamento

O primeiro `check_dft_rules`, executado antes de `syn_generic`, `syn_map` e `syn_opt`, reportou:

```text
Detected 0 DFT rule violation(s)
Total number of DFT violations: 0
Number of registers that fail DFT rules: 0
Number of registers that pass DFT rules: 40
Percentage of total registers that are scannable: 100%
```

Não foram encontradas violações de clock, reset assíncrono ou controlabilidade dos sinais de teste.

### 4.2 Após o mapeamento

O segundo `check_dft_rules`, executado após o mapeamento tecnológico, também reportou:

```text
Detected 0 DFT rule violation(s)
Total number of DFT violations: 0
Number of registers that fail DFT rules: 0
Number of registers that pass DFT rules: 40
Percentage of total registers that are scannable: 100%
```

Conclusão: as violações permaneceram em zero antes e depois do mapeamento. Todos os 40 registradores elegíveis passaram nas regras de DfT e puderam participar da estrutura de scan.

## 5. Report Scan Chains

O `report_scan_chains.rpt` mostrou:

```text
Reporting 1 scan chain (muxed_scan)

Chain 1: mac_chain
  scan_in:      scan_in
  scan_out:     scan_out
  shift_enable: SE (active high)
  clock_domain: clk (edge: rise)
  length: 40
```

Portanto:

| Métrica | Valor |
|---|---:|
| Número de chains, C | 1 |
| Nome da chain | `mac_chain` |
| SDI | `scan_in` |
| SDO | `scan_out` |
| Scan enable | `SE`, ativo alto |
| Domínio de clock | `clk`, borda de subida |
| Comprimento da chain | 40 |
| Nscan | 40 |
| Lmax | 40 |

A ordem da chain começa em `dut/busy_reg`, passa por `dut/count_reg[0]` até `dut/count_reg[10]`, inclui `dut/done_reg` e termina nos bits `dut/result_reg[0]` até `dut/result_reg[26]`.

## 6. Gates, Flip-Flops e Percentual em Scan

Como o `report_gates` não foi gerado nesta rodada, o número de registradores foi obtido do `check_dft_rules` e confirmado pelo `report_scan_chains`:

```text
Number of registers that pass DFT rules: 40
length: 40
```

Assim:

```text
NFF = 40
Nscan = 40
FFs em scan (%) = 100 * Nscan / NFF
FFs em scan (%) = 100 * 40 / 40
FFs em scan (%) = 100%
```

Na netlist DFT, foram encontrados 40 scan flip-flops. Os tipos usados foram:

| Célula scan FF | Quantidade |
|---|---:|
| `SDFFRHQX1` | 23 |
| `SDFFSRHQX1` | 8 |
| `SDFFSRX1` | 5 |
| `SDFFSRHQX2` | 4 |
| **Total** | **40** |

Na netlist sem DfT também foram encontrados 40 elementos sequenciais, distribuídos majoritariamente em células `DFF*`. A versão com DfT substituiu esses elementos por células `SDFF*`, que possuem entrada serial de scan e controle `SE`.

## 7. Área e Overhead

O `report_area_baseline.rpt` mostrou:

```text
mac_lab9_top: Cell-Count = 522
mac_lab9_top: Total-Area = 1368.821
```

O `report_area_scan.rpt` mostrou:

```text
mac_lab9_top: Cell-Count = 603
mac_lab9_top: Total-Area = 1632.486
```

O overhead de área é:

```text
DeltaArea (%) = 100 * (Area_DFT - Area_base) / Area_base
DeltaArea (%) = 100 * (1632.486 - 1368.821) / 1368.821
DeltaArea (%) = 19,26%
```

O número total de células aumentou de 522 para 603, um acréscimo de 81 células. Esse aumento é compatível com a substituição de flip-flops funcionais por scan flip-flops e com a lógica adicional associada à conexão da scan chain.

## 8. Timing

### 8.1 Sem DfT

O `report_timing_baseline.rpt` indicou:

```text
Path 1: MET (0 ps) Setup Check
Startpoint: b[4]
Endpoint: dut/result_reg[17]/D
Slack: 0 ps
```

O caminho crítico sem DfT parte da entrada `b[4]` e termina em `dut/result_reg[17]/D`.

### 8.2 Com DfT

O `report_timing_scan.rpt` indicou:

```text
Path 1: VIOLATED (-60 ps) Setup Check
Startpoint: b[7]
Endpoint: dut/result_reg[14]/D
Slack: -60 ps
```

O caminho crítico com DfT parte da entrada `b[7]` e termina em `dut/result_reg[14]/D`.

Comparação:

| Versão | WNS / pior slack | Status | Startpoint | Endpoint |
|---|---:|---|---|---|
| Sem DfT | 0 ps | MET | `b[4]` | `dut/result_reg[17]/D` |
| Com DfT | -60 ps | VIOLATED | `b[7]` | `dut/result_reg[14]/D` |

Após a inserção de scan, o pior slack piorou em 60 ps e passou a violar setup. O caminho crítico também mudou. Uma hipótese técnica é que os scan flip-flops possuem maior tempo de setup e maior carga associada às entradas de scan e ao roteamento, reduzindo a margem de temporização em caminhos que já estavam no limite.

## 9. Netlist DFT

A netlist DFT mostra que o Genus adicionou as portas `SE`, `scan_in` e `scan_out` ao top:

```verilog
module mac_lab9_top(clk, rst_n, start, valid, a, b, busy, done, result,
     SE, scan_in, scan_out);
  input clk, rst_n, start, valid, SE, scan_in;
  input [7:0] a, b;
  output busy, done, scan_out;
  output [26:0] result;
```

A instância da MAC recebe esses sinais de DfT:

```verilog
mac_param_DATA_WIDTH8_NUM_TERMS2048 dut(...,
     .dft_sdi (scan_in), .dft_sen (SE), .dft_sdo (scan_out));
```

O início da chain aparece em `busy_reg`, conectado à entrada serial `dft_sdi`:

```verilog
SDFFSRX1 busy_reg(..., .SI (dft_sdi), .SE (dft_sen), ...);
```

Em seguida, a chain segue pelos registradores do contador:

```verilog
SDFFRHQX1 \count_reg[0] (..., .SI (n_1194), .SE (dft_sen), ...);
SDFFRHQX1 \count_reg[1] (..., .SI (count[0]), .SE (dft_sen), ...);
```

Também há scan nos registradores do acumulador:

```verilog
SDFFSRHQX1 \result_reg[3] (..., .SI (n_1197), .SE (dft_sen), ...);
```

Esses trechos comprovam que os flip-flops foram substituídos por células scan com entradas `SI` e `SE`.

## 10. ScanDEF

O arquivo `mac_lab9_scan.scandef` confirmou a chain física exportada:

```text
SCANCHAINS 1 ;
  - mac_chain_seg1_clk_rising
    + PARTITION p_clk_rising
      MAXBITS 40
    + START PIN scan_in
    + FLOATING
       dut/busy_reg ( IN SI ) ( OUT QN )
       dut/count_reg[0] ( IN SI ) ( OUT Q )
       ...
       dut/result_reg[26] ( IN SI ) ( OUT Q )
    + STOP PIN scan_out
;
```

O ScanDEF registra a chain para etapas físicas posteriores, como place and route e possível scan reorder. Ele informa o início (`scan_in`), o fim (`scan_out`), o comprimento máximo de 40 bits e os elementos sequenciais pertencentes à chain.

## 11. Tempo de Shift com a Chain Real

O Genus reportou:

```text
Lmax = 40
```

Com shift a 100 MHz:

```text
Tbit = 10 ns
```

Tempo de uma fase de shift:

```text
Tshift_fase = Lmax * 10 ns
Tshift_fase = 40 * 10 ns
Tshift_fase = 400 ns
```

Para o teste dirigido do laboratório anterior, considerando preload, capture e unload:

```text
Tscan_total = 2 * Lmax * 10 ns + Tcapture
```

Usando clock funcional de 500 MHz para capture:

```text
Tcapture = 2 ns
Tscan_total = 2 * 40 * 10 ns + 2 ns
Tscan_total = 802 ns
Tscan_total = 0,802 us
```

## 12. Tabela de Resultados

| Métrica | Sem DfT | Com DfT | Fonte / observação |
|---|---:|---:|---|
| Total de flip-flops (NFF) | 40 | 40 | `check_dft_rules`, netlist |
| Scan flip-flops (Nscan) | N/A | 40 | `report_scan_chains` |
| FFs em scan (%) | N/A | 100% | `100 * 40 / 40` |
| Número de chains (C) | N/A | 1 | `report_scan_chains` |
| Comprimento da maior chain (Lmax) | N/A | 40 | `report_scan_chains` |
| Número total de células | 522 | 603 | `report_area` |
| Área total | 1368.821 | 1632.486 | `report_area` |
| Overhead de área (%) | N/A | 19,26% | cálculo |
| Área sequencial | N/D | N/D | `report_gates` não gerado |
| Pior slack (WNS) | 0 ps | -60 ps | `report_timing` |
| Violações DFT após map | N/A | 0 | `check_dft_rules` |
| Ports adicionados por DfT | N/A | `SE`, `scan_in`, `scan_out` | netlist DFT |
| Tempo de uma fase de shift | N/A | 400 ns | `Lmax * 10 ns` |

## 13. Respostas às Questões

### 13.1 Qual foi o valor de NFF e quantos desses flip-flops entraram em scan?

O valor de `NFF` foi 40. O número de flip-flops inseridos em scan foi `Nscan = 40`, conforme o `report_scan_chains`.

```text
Percentual de FFs em scan = 100 * 40 / 40 = 100%
```

Portanto, todos os flip-flops elegíveis entraram em scan. Nenhum registrador falhou nas regras de DfT.

### 13.2 Quantas scan chains foram criadas?

Foi criada uma única scan chain:

```text
Reporting 1 scan chain (muxed_scan)
Chain 1: mac_chain
```

O resultado corresponde ao mínimo solicitado no script, que configurou uma chain para o design `mac_lab9_top`.

### 13.3 Qual é o comprimento da maior chain?

O comprimento da maior chain é:

```text
Lmax = 40
```

Esse valor é maior que os 27 bits do acumulador porque a chain também inclui outros estados da MAC:

- `busy_reg`: 1 bit;
- `count_reg[0]` a `count_reg[10]`: 11 bits;
- `done_reg`: 1 bit;
- `result_reg[0]` a `result_reg[26]`: 27 bits.

Assim:

```text
1 + 11 + 1 + 27 = 40 bits
```

### 13.4 Quais células da biblioteca foram usadas como scan flip-flops?

Na netlist DFT, as células scan usadas foram:

| Célula | Quantidade |
|---|---:|
| `SDFFRHQX1` | 23 |
| `SDFFSRHQX1` | 8 |
| `SDFFSRX1` | 5 |
| `SDFFSRHQX2` | 4 |

Na versão sem DfT, os registradores aparecem principalmente como células `DFF*`. Após a inserção de scan, eles foram substituídos por células `SDFF*`, que possuem entradas adicionais de scan, como `SI` e `SE`.

### 13.5 Qual foi o overhead de área total?

O overhead de área total foi:

```text
Area_base = 1368.821
Area_DFT = 1632.486
DeltaArea = 19,26%
```

Esse aumento é compatível com a substituição de flip-flops funcionais por scan flip-flops, que incluem multiplexação interna para escolher entre o dado funcional e o dado serial de scan. Também há impacto de buffers e roteamento lógico adicional para suportar a chain.

### 13.6 O pior slack mudou após a inserção de scan?

Sim. O pior slack mudou de:

```text
Sem DfT: 0 ps
Com DfT: -60 ps
```

O caminho crítico também mudou:

```text
Sem DfT: b[4] -> dut/result_reg[17]/D
Com DfT: b[7] -> dut/result_reg[14]/D
```

Uma hipótese técnica é que a substituição por scan flip-flops aumentou a carga e o tempo de setup nos registradores de destino. Como a síntese sem DfT já estava exatamente no limite, com slack de 0 ps, o pequeno aumento causado por scan foi suficiente para gerar uma violação de -60 ps.

## 14. Conclusão

A inserção de full scan foi bem-sucedida. O Genus criou uma única scan chain do tipo `muxed_scan`, com `SE` ativo alto, `scan_in`, `scan_out`, domínio de clock `clk` e comprimento real de 40 bits.

Todos os 40 flip-flops elegíveis foram inseridos em scan, resultando em 100% de FFs em scan. A área total aumentou de 1368.821 para 1632.486, representando overhead de 19,26%. O timing piorou de 0 ps para -60 ps, indicando que a versão com DfT passou a apresentar uma pequena violação de setup.

Com `Lmax = 40` e shift a 100 MHz, uma fase de shift dura 400 ns. Para o teste dirigido com preload, capture e unload, o tempo estimado é 802 ns, considerando capture no clock funcional de 500 MHz.
