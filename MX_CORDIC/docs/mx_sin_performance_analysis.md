# Relatório de Aceleração: Hardware MX FP8 Decoder/Encoder vs. Implementação em Software

## 1. Escopo da análise

Esta análise compara **apenas o caminho de decodificação + re-codificação MX FP8** (blocos `u_decoder` e `u_encoder` do módulo `mx_sin`), excluindo o estágio de cálculo de seno (`phase_preprocess` / `LUT_Seno` / `phase_postprocess`). O objetivo é medir o ganho de desempenho isolado da conversão de formato (E5M2 → Q16.16 → E5M2), que é a parte diretamente comparável ao par `mx_decode()` / `mx_encode()` em software já modelado anteriormente.

Cada operação processa **um bloco de 4 elementos em paralelo**, tanto no hardware quanto no software (a função em software também opera sobre os 4 elementos de uma vez, então a comparação é por bloco, sem necessidade de fator de escala adicional).

## 2. Premissas

| Parâmetro | Valor |
|---|---|
| Ciclos de hardware por bloco (decode+encode) | 2 – 3 ciclos  |
| Paralelismo do hardware | 4 elementos simultâneos |
| CPI (ciclos por instrução) do processador | 4 – 5 ciclos/instrução (caso médio) |
| Instruções por bloco em software | ver seção 3 |
| Frequência de clock | assumida igual para HW e SW |

## 3. Contagem de instruções em software (recapitulação)

Baseado na tradução RV32I feita anteriormente para `mx_decode` (decoder) e `mx_encode` (encoder):

| Função | Melhor caso | Caso típico |
|---|---:|---:|
| `mx_decode` (E5M2 → Q16.16) | ~107 instr. (NaN/Inf, saída antecipada) | **~175 instr.** |
| `mx_encode` (Q16.16 → E5M2) | ~66 instr. (todos os valores = 0) | **~345 instr.** |
| **Total por bloco (decode + encode)** | ~173 instr. | **~520 instr.** |

O caso típico é o mais representativo para uma estimativa de desempenho médio (o caso "melhor" exige simultaneamente NaN no decode *e* magnitude zero no encode, uma combinação pouco frequente na prática). A análise de aceleração abaixo usa o **caso típico (520 instruções)** como referência central, com os extremos (melhor/pior CPI e ciclos de hardware) usados para dar um intervalo de confiança.

## 4. Ciclos de execução

### 4.1 Software (processador escalar)

$$
\text{ciclos}_{SW} = \text{instruções} \times \text{CPI}
$$

| Cenário | Instruções | CPI | Ciclos de software |
|---|---:|---:|---:|
| Mínimo (favorável ao SW) | 520 | 4 | 2.080 ciclos |
| Médio | 520 | 4,5 | 2.340 ciclos |
| Máximo (desfavorável ao SW) | 520 | 5 | 2.600 ciclos |

### 4.2 Hardware (mx_sin, decode+encode)

| Cenário | Ciclos de hardware |
|---|---:|
| Mínimo | 2 ciclos |
| Médio | 2,5 ciclos |
| Máximo | 3 ciclos |

O hardware já processa os 4 elementos do bloco em paralelo dentro desses 2-3 ciclos (estágios de pipeline registrados), então nenhum fator de escala adicional é necessário — a unidade de comparação (1 bloco de 4 elementos) é a mesma dos dois lados.

## 5. Aceleração (speedup)

$$
\text{speedup} = \frac{\text{ciclos}_{SW}}{\text{ciclos}_{HW}}
$$

| Cenário | Ciclos SW | Ciclos HW | **Speedup** |
|---|---:|---:|---:|
| Pior caso para o hardware (SW rápido, HW lento) | 2.080 | 3 | **≈ 693×** |
| Caso médio | 2.340 | 2,5 | **≈ 936×** |
| Melhor caso para o hardware (SW lento, HW rápido) | 2.600 | 2 | **≈ 1.300×** |

**Resultado central: o bloco dedicado em hardware é aproximadamente 700× a 1.300× mais rápido que a rotina equivalente em software escalar, com estimativa média em torno de ~936×.**

## 6. Ressalvas e limitações da estimativa

- **Mesma frequência de clock assumida.** O speedup acima é medido em *ciclos*, não em tempo absoluto. Se o núcleo em hardware (ASIC/FPGA) roda a uma frequência menor que o processador de referência, o ganho real em tempo (segundos) deve ser ajustado pela razão das frequências: `speedup_tempo = speedup_ciclos × (f_HW / f_SW)`.
- **Processador escalar, sem extensões.** A contagem de 520 instruções assume RV32I puro, sem `clz` nativo (Zbb) — a função auxiliar `msb_index` sozinha soma cerca de 23 instruções por chamada e é invocada 5 vezes por bloco (~35% do custo total do encoder). Um core com Zbb reduziria o total de software para ~215-230 instruções, encolhendo o speedup médio para a faixa de **~400×-500×** — ainda assim, uma ordem de grandeza dominada pelo hardware.
- **CPI de 4-5 é uma média genérica**, não fruto de simulação ciclo-a-ciclo de um core específico; pipelines superescalares modernos poderiam ter CPI menor que 4 para código simples e reduzir a distância, enquanto cores in-order simples com stalls de memória/branch poderiam facilmente superar 5.

## 7. Conclusão

Para a operação isolada de decodificação e recodificação MX FP8 (E5M2 ↔ Q16.16), o bloco dedicado em hardware (`u_decoder` + `u_encoder` do `mx_sin`) entrega uma aceleração estimada de **~700× a ~1.300×** (média ~936×) em relação à mesma lógica implementada como código RV32I escalar rodando a 4-5 ciclos por instrução. Esse ganho é dominado, do lado do software, pelo custo de operações que o hardware faz "de graça" em um ciclo (deslocamentos variáveis, `clz`/prioridade de bit, saturação) mas que em RV32I puro exigem dezenas de instruções sequenciais — especialmente a busca do bit mais significativo (`msb_index`), repetida 5 vezes por bloco no encoder.