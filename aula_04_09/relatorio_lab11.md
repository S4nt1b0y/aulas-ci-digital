# Relatório Lab 11 - Planejamento de Teste da MAC

## 1. Objetivo

Este relatório analisa o planejamento de teste de uma unidade MAC unsigned usando três estratégias:

- Teste funcional sem Design for Test (DfT);
- BIST determinístico;
- Full scan com uma scan chain.

O objetivo é comparar controlabilidade, observabilidade, tempo de ocupação do ATE e custo de teste por die.

## 2. Sistema Sob Teste

A unidade sob teste é a MAC unsigned descrita em `mac_param.v`, com a operação:

```text
ACC_next = ACC + A * B
```

Para este laboratório, a MAC foi considerada com os seguintes parâmetros:

| Parâmetro | Valor |
|---|---:|
| Largura de A | 8 bits |
| Largura de B | 8 bits |
| Número de multiplicações-acumulações | 2048 |
| Largura do acumulador | 27 bits |
| Clock disponível no ATE | 100 MHz |
| Período do ATE | 10 ns |
| Clock funcional interno | 500 MHz |
| Período interno | 2 ns |
| Dies testados em paralelo | 32 |
| Custo do ATE | US$ 500/hora |

A condição dirigida solicitada pelo fabricante é:

```text
ACC_pre = 67.108.863 = 2^26 - 1
A = 1
B = 1
ACC_pos = 67.108.864 = 2^26
```

Ou seja:

```text
67.108.863 + (1 * 1) = 67.108.864
```

Em binário, a transição esperada do acumulador é:

```text
ACC_pre = 27'b0_11111111111111111111111111
ACC_pos = 27'b1_00000000000000000000000000
```

Essa condição causa a transição de todos os 27 bits do acumulador entre o estado anterior e posterior.

## 3. Estratégia A - Teste Funcional Sem DfT

Nesta estratégia, não há scan chain, BIST, preload de registradores ou acesso especial ao acumulador. Portanto, o estado interno `ACC = 67.108.863` precisa ser atingido exclusivamente pela aplicação de operandos nos pinos funcionais `A` e `B`.

Como o ATE só consegue aplicar novos valores nos pinos a cada 10 ns, cada multiplicação-acumulação consome um ciclo de ATE.

A sequência dirigida usada na simulação foi:

| Quantidade | A | B | Produto |
|---:|---:|---:|---:|
| 1031 | 255 | 255 | 65025 |
| 1 | 237 | 14 | 3318 |
| 1 | 255 | 254 | 64770 |

A soma acumulada antes da operação alvo é:

```text
1031 * 65025 + 237 * 14 + 255 * 254
= 67.108.863
```

Depois de atingir `ACC_pre`, aplica-se a operação alvo:

| Quantidade | A | B | Produto |
|---:|---:|---:|---:|
| 1 | 1 | 1 | 1 |

Assim:

```text
67.108.863 + 1 * 1 = 67.108.864
```

### 3.1 Resultado da Simulação

A simulação confirmou:

```text
ACC_pre atingido apos 1033 operacoes: 67108863
ACC_pos atingido apos A=1, B=1: 67108864
Operacoes ate observar a condicao: 1034
Tempo funcional no ATE: 10.340 us
Custo por die: US$ 0.000000044878
```

O tempo de teste funcional é:

```text
T_funcional = 1034 ciclos * 10 ns
T_funcional = 10.340 ns
T_funcional = 10,340 us
```

O custo por die é:

```text
Custo = tempo_em_segundos * (US$ 500 / 3600 s) / 32
Custo = 10,340e-6 * (500 / 3600) / 32
Custo = US$ 0,000000044878
```

Portanto:

```text
Custo funcional por die ~= US$ 4,49e-8
```

## 4. Estratégia B - BIST Determinístico

No BIST determinístico, o ATE não aplica todos os operandos diretamente nos pinos a cada ciclo. Em vez disso, o ATE apenas inicia o teste e lê os sinais finais `done` e `pass`.

Internamente, o BIST contém:

- FSM de controle;
- Contador de 11 bits;
- Gerador determinístico de operandos;
- Comparador final.

O contador de 11 bits é usado porque:

```text
2^11 = 2048
```

Assim, ele é suficiente para controlar o bloco completo de 2048 multiplicações-acumulações.

O BIST executa a sequência de teste no clock funcional interno de 500 MHz. Portanto:

```text
T_INT = 2 ns
```

Considerando o bloco completo:

```text
T_BIST = 2048 ciclos * 2 ns
T_BIST = 4096 ns
T_BIST = 4,096 us
```

O custo por die é:

```text
Custo = 4,096e-6 * (500 / 3600) / 32
Custo = US$ 0,000000017778
```

Portanto:

```text
Custo BIST por die ~= US$ 1,78e-8
```

A vantagem do BIST é reduzir o tempo de ocupação do ATE, pois a geração dos vetores e a verificação ocorrem dentro do chip, em clock interno mais rápido. A desvantagem é o aumento de área devido à inserção da FSM, contador, gerador determinístico e comparador.

## 5. Estratégia C - Full Scan

Na estratégia full scan, os flip-flops elegíveis da MAC são substituídos por scan flip-flops conectados em uma scan chain. Isso permite carregar diretamente o estado interno do acumulador e deslocar a resposta para fora após a captura.

O procedimento conceitual é:

```text
1. Ativar scan_enable.
2. Deslocar a scan chain para carregar ACC = 67.108.863.
3. Aplicar A = 1 e B = 1 nos pinos funcionais.
4. Desativar scan_enable.
5. Aplicar um ciclo funcional de capture.
6. Reativar scan_enable.
7. Deslocar a resposta para fora e observar ACC = 67.108.864.
```

Na ausência do relatório real do Genus, foi feita uma estimativa RTL dos flip-flops elegíveis:

| Registrador | Largura |
|---|---:|
| `result` / acumulador | 27 bits |
| `count` | 11 bits |
| `busy` | 1 bit |
| `done` | 1 bit |
| **Total estimado** | **40 FFs** |

Logo:

```text
Nscan_estimado = 27 + 11 + 1 + 1
Nscan_estimado = 40
```

Para uma única scan chain:

```text
C = 1
L = ceil(Nscan / C)
L = ceil(40 / 1)
L = 40
```

O shift é limitado pelo ATE a 100 MHz:

```text
T_shift = 10 ns por bit
```

O tempo estimado para preload, capture e unload é:

```text
T_scan = L * 10 ns + T_capture + L * 10 ns
T_scan = 40 * 10 ns + 2 ns + 40 * 10 ns
T_scan = 802 ns
T_scan = 0,802 us
```

O custo por die é:

```text
Custo = 0,802e-6 * (500 / 3600) / 32
Custo = US$ 0,000000003481
```

Portanto:

```text
Custo scan por die ~= US$ 3,48e-9
```

Observação: o valor `Nscan = 40` é uma estimativa baseada no RTL. O valor definitivo deve ser obtido pelo relatório `report_scan_chains` do Cadence Genus, pois a ferramenta pode otimizar registradores ou alterar a implementação durante a síntese.

## 6. Comparação dos Resultados

| Estratégia | Tempo do teste | Custo ATE / die | Delta de área |
|---|---:|---:|---|
| Sem DfT | 10,340 us | US$ 4,49e-8 | 0% |
| BIST | 4,096 us | US$ 1,78e-8 | Maior; adiciona FSM, contador, gerador e comparador |
| Scan - 1 chain | 0,802 us | US$ 3,48e-9 | Médio; troca FFs por scan FFs e adiciona roteamento |

## 7. Discussão

O teste funcional sem DfT tem a menor área adicional, pois não exige hardware específico de teste. Porém, ele depende completamente do ATE para aplicar os operandos pelos pinos funcionais. Como o ATE é limitado a 100 MHz, o tempo de teste é maior.

O BIST determinístico reduz o tempo de ocupação do ATE porque os vetores são gerados internamente e aplicados no clock funcional de 500 MHz. O ATE apenas inicia o teste e lê o resultado final. A principal desvantagem é o overhead de área, pois é necessário inserir lógica adicional de teste.

O full scan oferece a maior controlabilidade e observabilidade, pois permite carregar diretamente estados internos e observar a resposta deslocando a scan chain. Para a condição dirigida deste laboratório, ele apresenta o menor tempo estimado. Entretanto, também há overhead de área, pois os flip-flops funcionais são substituídos por scan flip-flops e é necessário adicionar o roteamento da chain.

## 8. Conclusão

A comparação mostra o trade-off clássico de DfT. A estratégia sem DfT preserva área, mas aumenta o tempo de teste. O BIST reduz a dependência do ATE e usa o clock interno mais rápido, mas adiciona hardware dedicado. O full scan apresenta excelente controlabilidade e observabilidade, além de menor tempo para o teste dirigido, mas exige scan flip-flops e infraestrutura de scan.

Para a entrega final, o valor estimado de `Nscan = 40` deve ser substituído pelo valor real obtido no `report_scan_chains` caso a síntese com DfT seja executada no Cadence Genus.
