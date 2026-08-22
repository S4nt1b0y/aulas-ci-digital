# Relatorio do experimento - Aula 07/08

## Introducao

Este relatorio analisa as simulacoes realizadas para os circuitos `x3_curto` e `mac_param`.
Para cada circuito foram considerados tres niveis de simulacao:

1. Simulacao RTL.
2. Simulacao gate-level (GLS) sem anotacao SDF.
3. Simulacao gate-level (GLS) com anotacao SDF.

Os testbenches dos dois circuitos usam clock com periodo de 10 ns, equivalente a 100 MHz. Ja os relatorios de sintese/timing foram gerados com restricao de clock de 0,42 ns, equivalente a aproximadamente 2,38 GHz. Essa diferenca e importante: o clock usado no testbench e bem menos agressivo que o alvo de timing usado na sintese.

Como nao ha transcripts completos das simulacoes salvos na pasta `aula_07_08`, as tabelas abaixo diferenciam resultados observados nos logs/relatorios daqueles que foram observados nas capturas de waveform do PDF `Documento sem titulo.pdf`.

## Experimento 1: circuito x3_curto

O circuito `x3_curto` calcula uma potencia ao cubo em tres estagios de registradores. O testbench aplica os valores `2`, `3`, `4`, `5`, `10` e `20`, com clock de 10 ns, e imprime `X` e `XPower` a cada borda positiva.

| Tentativa | Periodo do clock | Frequencia | Timing violation? | X inesperado? | Resultado funcional |
|---|---:|---:|---|---|---|
| 1 - RTL | 10 ns | 100 MHz | Nao ha evidencia de violation em RTL | Apenas `xx` inicial em `XPower`, esperado antes de o pipeline preencher | Funcional: a waveform mostra `XPower` estabilizando em `00`, `08`, `1B`, `40`, `7D`, `E8`, `40` para os estimulos aplicados |
| 2 - GLS sem SDF | 10 ns | 100 MHz | Nao ha atrasos SDF anotados; sem evidencia registrada de violation na simulacao | Nao registrado diretamente nos logs disponiveis | Esperado: equivalente ao RTL para os vetores aplicados |
| 3 - GLS com SDF | 10 ns | 100 MHz | Sem violation registrada no transcript; porem a sintese indica violacao para o alvo de 0,42 ns | Sim, aparecem janelas transientes de `x`/`xx` em sinais internos e em `XPower` antes da estabilizacao | Funcional em 100 MHz nas capturas: apesar dos transientes, `XPower` estabiliza nos mesmos valores finais do RTL |

No relatorio de timing da sintese, o alvo de clock foi `0,42 ns`. Para esse alvo, o circuito nao fechou timing: o pior caminho apresenta slack de aproximadamente `-785 ps`, com chegada em `1107 ps`. O caminho critico reportado vai de `X2_reg[0]/CK` ate `XPower_reg[7]/D`. O relatorio de QoR tambem indica 14 caminhos violados e TNS de aproximadamente `-4712 ps`.

Assim, em termos temporais, a sintese mostra que o circuito nao atenderia ao periodo de 0,42 ns. Entretanto, no testbench com periodo de 10 ns, ha margem muito maior, o que explica por que uma GLS com SDF pode continuar funcional para esses estimulos.

Nas waveforms do PDF, a simulacao RTL mostra `XPower` inicialmente indefinido e depois estabilizando na sequencia esperada. A captura GLS com SDF mostra comportamento diferente: entre algumas bordas de clock aparecem valores `x`/`xx` temporarios em `XPower`, `X1`, `X2`, `XPower1`, `XPower2` e em nets internas. Esses `X` nao aparecem como valor final estavel no ponto de observacao principal, mas indicam o efeito temporal da netlist com atrasos anotados.

## Experimento 2: circuito mac_param

O circuito `mac_param` implementa uma operacao MAC acumulando `NUM_TERMS = 1024` produtos. No testbench, `a1` recebe o indice `i`, `b1` recebe `2`, e o resultado final e comparado com `expected1`.

| Tentativa | Periodo do clock | Frequencia | Timing violation? | X inesperado? | Resultado funcional |
|---|---:|---:|---|---|---|
| 1 - RTL | 10 ns | 100 MHz | Nao ha evidencia de violation em RTL | Apenas valores iniciais indefinidos antes/reset no inicio da simulacao | Funcional: waveform mostra `busy1` ativo, `valid1` habilitando as amostras e `result1` acumulando `0`, `2`, `6`, `C`, `14`... |
| 2 - GLS sem SDF | 10 ns | 100 MHz | Nao ha atrasos SDF anotados; sem evidencia registrada de violation na simulacao | Nao registrado diretamente nos logs disponiveis | Esperado: equivalente ao RTL para os vetores aplicados |
| 3 - GLS com SDF | 10 ns | 100 MHz | Sem violation registrada no transcript; porem a sintese indica violacao para o alvo de 0,42 ns | Nao ha `X` inesperado visivel nos sinais principais apos a inicializacao; ha muitos sinais internos da netlist expostos | Funcional nas capturas iniciais em 100 MHz; em frequencias altas pode falhar |

No relatorio de timing da sintese, tambem com alvo de `0,42 ns`, a MAC apresenta violacao mais severa que o `x3_curto`: o pior slack e de aproximadamente `-1439 ps`, com chegada em `1732 ps`. O caminho critico vai de `result_reg[9]/CK` ate `result_reg[17]/D`. O relatorio de QoR indica 38 caminhos violados e TNS de aproximadamente `-36129 ps`.

Esses dados mostram que a MAC tem uma logica combinacional mais pesada entre registradores, principalmente no caminho do acumulador `result`, o que torna o circuito mais sensivel ao aumento de frequencia.

Nas capturas de waveform da MAC, os sinais de controle confirmam a operacao esperada no inicio da sequencia: `start1` inicia a operacao, `busy1` fica ativo, `valid1` passa a indicar entradas validas, `a1` cresce sequencialmente e `b1` permanece em `2`. O sinal `result1` acompanha a acumulacao: aparecem valores como `0`, `2`, `6`, `C`, `14`, `1E`, `2A`, `38`, `48`, `5A` e `6E`, coerentes com a soma acumulada de `i*2` nos primeiros ciclos. A captura GLS tambem mostra sinais internos expandidos da netlist, o que ajuda a investigar falhas temporais caso o resultado externo deixe de bater com `expected1`.

## Questoes para analise

### 1. Qual diferenca funcional ou temporal foi observada entre a simulacao RTL e a GLS sem SDF?

Funcionalmente, a expectativa e que RTL e GLS sem SDF apresentem o mesmo comportamento para os vetores testados, pois a netlist sintetizada deve preservar a logica do RTL. A principal diferenca e estrutural: na GLS, o circuito passa a ser representado por portas e registradores da biblioteca tecnologica, em vez de descricoes comportamentais.

Temporalmente, a GLS sem SDF ainda nao contem os atrasos reais do arquivo SDF. Portanto, ela nao e adequada para medir propagacao real de sinais nem para concluir fechamento de timing. Ela pode, entretanto, expor diferencas de inicializacao ou propagacao de `X` que nao aparecem de forma tao evidente no RTL. No caso do `x3_curto`, a waveform RTL mostra a saida preenchendo o pipeline de forma limpa depois do `xx` inicial; na visao gate-level, aparecem mais sinais internos e mais oportunidades de visualizar estados indefinidos.

### 2. Qual diferenca foi observada entre a GLS sem SDF e a GLS com SDF?

A GLS com SDF inclui atrasos de celulas, atrasos de caminhos `IOPATH` e checks temporais como setup e hold. Com isso, as transicoes deixam de ser ideais e passam a ocorrer depois dos atrasos anotados.

Na pratica, isso permite observar atrasos na waveform, propagacao temporaria de `X` e possiveis falhas em frequencias altas. No `x3_curto`, a captura com SDF mostra `XPower` passando por regioes `xx`/`x` antes de estabilizar. Essa diferenca e especialmente importante para a MAC, pois o relatorio de timing mostra caminho critico com chegada em `1732 ps`, muito maior que o periodo de sintese de `420 ps`.

### 3. Quais evidencias demonstram que o arquivo SDF foi efetivamente anotado?

As evidencias sao:

- Os dois testbenches chamam `$sdf_annotate("delays.sdf", ..., "sdf.log", "MAXIMUM")`.
- O `sdf.log` de `mac_param` registra `Backannotation scope: mac_param_tb.dut`, `MTM control: MAXIMUM` e `Time units: 1ns`.
- O `sdf.log` de `mac_param` possui 531 instancias anotadas, incluindo buffers, portas logicas e registradores.
- Os arquivos `delays.sdf` de `x3_curto` e `mac_param` declaram `SDFVERSION "OVI 3.0"`, `TIMESCALE 1ns`, tensao de `0.9 V`, temperatura de `125 C` e atrasos `IOPATH`.
- O `sdf.log` de `x3_curto` registra o cabecalho de backannotation para o escopo `x3_curto_tb.dut`. Ele nao contem a listagem detalhada de instancias no arquivo salvo, entao a evidencia mais forte para esse circuito e a existencia do SDF gerado junto com a chamada de anotacao no testbench.

### 4. Qual atraso foi medido na waveform do circuito x3? Indique os sinais e os instantes utilizados na medicao.

O PDF apresenta uma captura ampliada do `x3_curto` em torno de `45 ns`. Nela, o cursor esta em `TimeA = 45,000 ps`, no instante em que `X` passa para `05`. Nesse mesmo ponto, `XPower` ainda aparece com o valor anterior (`08`) e passa a refletir o novo resultado logo depois, estabilizando em `1B` para o vetor anterior da sequencia.

A captura nao mostra um segundo cursor com delta numerico exato, entao a medicao visual so permite concluir qualitativamente que ha atraso de estabilizacao apos a borda de clock. O relatorio de timing da sintese complementa essa leitura com o valor quantitativo do caminho critico: de `X2_reg[0]/CK` ate `XPower_reg[7]/D`, a chegada e de `1107 ps`. Portanto, o atraso relevante no `x3_curto` esta associado ao caminho que parte do registrador `X2` e chega ao registrador de saida `XPower`.

### 5. Na MAC, quais sinais foram mais uteis para identificar que o circuito deixou de operar corretamente?

Os sinais mais uteis foram:

- `result1`, por ser a saida acumulada do circuito.
- `expected1`, por ser o valor de referencia calculado no testbench.
- `done1`, pois indica o momento em que a comparacao final deve ser feita.
- `busy1`, pois mostra se o circuito esta dentro da janela ativa de acumulacao.
- `valid1`, pois indica quais ciclos devem contribuir para o acumulador.
- `a1` e `b1`, pois permitem conferir quais produtos foram aplicados.

Quando disponivel na waveform, o contador interno `count` tambem e muito util, porque permite relacionar cada acumulacao ao indice do termo que esta sendo processado. Nas capturas do PDF, `result1` e `expected1` aparecem juntos, e isso facilita identificar divergencia: se `done1` for acionado e `result1` nao coincidir com `expected1`, o erro funcional fica evidente. `busy1`, `valid1` e `count` ajudam a localizar em qual trecho da acumulacao a divergencia comecou.

### 6. A regiao de frequencia em que a MAC comecou a falhar foi facil de identificar? Quais estimulos ajudaram a evidenciar a falha?

Nao e uma regiao totalmente facil de identificar com uma unica sequencia de simulacao, porque a falha depende dos caminhos sensibilizados pelos vetores de entrada e do estado interno do acumulador. A MAC pode funcionar para alguns padroes e falhar para outros mesmo no mesmo periodo de clock.

Os estimulos mais uteis para evidenciar falha foram os estimulos longos e acumulativos do testbench: 1024 ciclos com `valid1` ativo, `a1 = i` e `b1 = 2`. Essa sequencia exercita repetidamente a multiplicacao, a soma e a realimentacao de `result`, aumentando a chance de sensibilizar caminhos criticos do acumulador.

### 7. Por que uma GLS pode executar corretamente em determinada frequencia para alguns vetores e falhar para outros?

Porque nem todos os vetores exercitam os mesmos caminhos logicos. Uma violacao temporal so aparece funcionalmente quando o vetor aplicado sensibiliza um caminho lento e quando o valor errado chega a tempo de ser capturado por algum registrador ou observado na saida.

Tambem ha diferenca entre transicoes de subida e descida, carregamentos de fanout, profundidade logica ativada e estado previo dos registradores. Assim, uma frequencia pode parecer segura para uma sequencia simples, mas falhar com outra sequencia que ativa o caminho critico real.

### 8. Quais limitacoes existem em concluir que um circuito "funciona em uma frequencia" apenas porque uma sequencia de GLS nao apresentou erro?

Uma sequencia de GLS sem erro prova apenas que aqueles vetores especificos passaram naquele cenario de simulacao. Isso nao garante cobertura de todos os caminhos, todos os estados internos, todas as transicoes nem todos os cantos de processo, tensao e temperatura.

Tambem nao garante que todos os checks temporais relevantes foram exercitados. Por isso, concluir que um circuito funciona em uma frequencia exige combinar simulacao com analise estatica de timing, cobertura adequada de vetores e, quando necessario, simulacoes em diferentes cantos e condicoes.

## Conclusao

Os experimentos mostram a diferenca entre verificar a funcao logica e verificar o comportamento temporal de um circuito sintetizado. Em RTL e em GLS sem SDF, a analise fica centrada na equivalencia funcional. Com SDF, passam a aparecer os atrasos reais da biblioteca e a possibilidade de falhas temporais.

Nos dois circuitos, os testbenches usam 10 ns, mas a sintese foi avaliada com 0,42 ns. Para esse alvo agressivo, tanto o `x3_curto` quanto o `mac_param` apresentam violacoes de setup, sendo a MAC o caso mais critico. Isso reforca que passar em uma simulacao funcional nao e suficiente para afirmar que o circuito fecha timing em uma frequencia alta.
