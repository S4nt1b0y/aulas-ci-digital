# Relatorio LAB10 - Analises apos a sintese

## 4. Analises apos a sintese

O circuito sintetizado corresponde ao modulo `aFifo`, uma FIFO assincrona com dois dominios de clock:

- `WClk`, usado no dominio de escrita, com periodo de 10 ns.
- `RClk`, usado no dominio de leitura, com periodo de 12,5 ns.

A sintese gerou o netlist pos-sintese `aFifo_netlist.v`, o SDC pos-sintese `aFifo_syn.sdc` e os reports em `reports/`. A analise de timing foi feita no corner slow (`PVT_0P9V_125C`), usando a biblioteca `slow_vdd1v0_basicCells.lib`.

O `report_qor.rpt` indica 416 instancias leaf, sendo 176 sequenciais e 240 combinacionais. O mesmo report mostra que os dois dominios de clock possuem slack positivo e TNS igual a zero, portanto nao ha violacoes de setup nos dominios analisados.

## 5. Latches e sincronizadores de ponteiro Gray

Nao foram inferidos latches. No `reports/report_power.rpt`, a categoria `latch` aparece com potencia total igual a `0.00000e+00` e participacao `0.00%`, enquanto a categoria `register` aparece separadamente, confirmando que os elementos sequenciais usados foram registradores/flops.

Os dois sincronizadores de ponteiro Gray sao:

- Sincronizador do ponteiro de escrita no dominio de leitura (`RClk`): `Next_Write_addr_1[*]` e `Next_Write_addr_2[*]`.
- Sincronizador do ponteiro de leitura no dominio de escrita (`WClk`): `Next_Read_addr_1[*]` e `Next_Read_addr_2[*]`.

No RTL (`aFifo.v`), o ponteiro `pNextWordToWrite` e amostrado em dois estagios por `Next_Write_addr_1` e `Next_Write_addr_2` no bloco sensivel a `posedge RClk`. Da mesma forma, o ponteiro `pNextWordToRead` e amostrado em dois estagios por `Next_Read_addr_1` e `Next_Read_addr_2` no bloco sensivel a `posedge WClk`.

No netlist pos-sintese, estes registradores aparecem como:

- `Next_Write_addr_1_reg[0]` a `Next_Write_addr_1_reg[4]`, clockados por `RClk`.
- `Next_Write_addr_2_reg[0]` a `Next_Write_addr_2_reg[4]`, clockados por `RClk`.
- `Next_Read_addr_1_reg[0]` a `Next_Read_addr_1_reg[4]`, clockados por `WClk`.
- `Next_Read_addr_2_reg[0]` a `Next_Read_addr_2_reg[4]`, clockados por `WClk`.

## 6. Setup nos dominios WClk e RClk

Sim, o circuito atende setup nos dois dominios.

| Clock | Periodo | WNS / critical slack | TNS | Caminhos violadores | Pior caminho reportado |
| --- | ---: | ---: | ---: | ---: | --- |
| `WClk` | 10000.0 ps | 7386.1 ps | 0.0 ps | 0 | `WriteEn_in` -> `Mem_reg[0][7]/SE` |
| `RClk` | 12500.0 ps | 9493.4 ps | 0.0 ps | 0 | Nao detalhado no `aFifo_setup_slow.rpt` salvo |

Fonte dos valores por clock: `reports/report_qor.rpt`.

O report detalhado `reports/aFifo_setup_slow.rpt` foi gerado com `report_timing -max_paths 10`. Os 10 caminhos salvos sao os piores caminhos globais e todos pertencem ao grupo `WClk`. Por isso, o valor de WNS/TNS de `RClk` e confirmado pelo `report_qor.rpt`, mas o caminho detalhado de `RClk` nao aparece no report detalhado final.

## 7. Classificacao dos piores caminhos

### Dominio WClk

O pior caminho detalhado salvo e do tipo `in2reg`, pois parte de uma entrada primaria (`WriteEn_in`) e termina em um registrador (`Mem_reg[0][7]/SE`).

Dados do caminho:

- Grupo: `WClk`.
- Startpoint: `WriteEn_in`.
- Endpoint: `Mem_reg[0][7]/SE`.
- Slack: 7386 ps no report detalhado; 7386.1 ps no resumo/QoR.
- Constraint aplicada: `input_delay` de 1500 ps.

Blocos logicos no caminho:

1. `WriteEn_in`
2. `NAND2BX1`
3. `NOR2X1`
4. `NOR2BX1`
5. `NAND2X1`
6. `NAND2BX1`
7. `SDFFQX1` (`Mem_reg[0][7]`)

Esse caminho representa a logica de habilitacao da escrita na memoria da FIFO, indo da entrada de enable de escrita ate o pino de scan-enable/enable do registrador da memoria sintetizada.

### Dominio RClk

O pior caminho de `RClk` atende setup, com critical slack de 9493.4 ps, TNS de 0.0 ps e 0 caminhos violadores no `report_qor.rpt`.

Entretanto, o report detalhado `aFifo_setup_slow.rpt` nao contem o caminho completo de `RClk`, porque foram salvos apenas os 10 piores caminhos globais e todos pertencem ao grupo `WClk`. Assim, a classificacao detalhada `in2reg`, `reg2reg` ou `reg2out` do pior caminho de `RClk` nao deve ser inferida a partir dos reports finais disponiveis. Para obter essa classificacao com evidencia direta, seria necessario gerar um novo report de timing filtrado para o grupo `RClk`.

## 8. Clocks assincronos, ausencia de setup entre dominios e timing lint

Os clocks `WClk` e `RClk` sao tratados como assincronos.

No SDC principal (`constraint.sdc`), a restricao usada foi:

```tcl
set_clock_groups -asynchronous -group {WClk} -group {RClk}
```

No SDC pos-sintese (`aFifo_syn.sdc`), a mesma intencao foi preservada como:

```tcl
set_clock_groups -name "clock_groups_WClk_to_RClk" -asynchronous -group [get_clocks WClk] -group [get_clocks RClk]
```

Com essa restricao, a ferramenta nao realiza analise convencional de setup entre os dominios `WClk` e `RClk`. A analise de setup fica restrita aos caminhos dentro de cada dominio e aos caminhos de entrada/saida associados aos clocks definidos.

O timing lint esta limpo. Em `reports/aFifo_lint_slow.rpt`, todos os itens aparecem com contagem zero e o total final e:

```text
Total: 0
```

Itens importantes confirmados com zero ocorrencias:

- Clocks sequenciais sem waveform.
- Clocks sequenciais com multiplas waveforms.
- Caminhos constrained com clocks diferentes.
- Entradas sem delays externos clockados.
- Saidas sem delays externos clockados.
- Excecoes de timing sem efeito.
- Excecoes com startpoints/endpoints invalidos.

Portanto, os reports confirmam que nao ha caminhos funcionais sem constraint indicados pelo timing lint.

## Conclusao

O circuito sintetizado atende setup nos dominios `WClk` e `RClk`, nao apresenta latches inferidos, possui sincronizadores Gray de dois estagios para os ponteiros cruzando entre os dominios e trata corretamente os clocks como assincronos por meio de `set_clock_groups -asynchronous`. O timing lint final nao acusa erros, totalizando zero ocorrencias.
