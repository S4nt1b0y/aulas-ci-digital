# LAB8 - Detector de Padrao por Correlacao

Este laboratorio implementa um detector de padrao por correlacao usando:

- buffer circular parametrizavel;
- uma MAC signed reutilizada/adaptada dos laboratorios anteriores;
- uma FSM de controle;
- ROM externa sincrona, fora do bloco sintetizado.

Para `N=8`, a correlacao calculada e:

```text
y[n] = sum(k=0..7) x[n-k] * h[k]
```

com `h[0]` associado a amostra mais recente.

Os coeficientes usados no testbench para `N=8` sao:

```text
{12000, -8000, 16000, 4000, -14000, 10000, -6000, 14000}
```

## Interface do Topo

O modulo principal e `pattern_detector`.

Entradas principais:

- `clk`: clock do detector e tambem da ROM externa.
- `rst_n`: reset assincrono ativo em zero.
- `in_data`: amostra signed de 16 bits.
- `in_valid`: indica que a fonte tem uma amostra valida.
- `out_ready`: indica que o consumidor pode aceitar o resultado.
- `rom_data`: coeficiente signed de 16 bits vindo da ROM externa.

Saidas principais:

- `in_ready`: indica que o detector pode aceitar uma nova amostra.
- `rom_addr`: endereco enviado para a ROM externa.
- `out_data`: resultado signed da correlacao.
- `out_valid`: indica que `out_data` contem resultado valido.

A entrada e aceita somente quando:

```text
in_valid && in_ready
```

A saida e consumida somente quando:

```text
out_valid && out_ready
```

Enquanto o detector esta calculando uma correlacao ou segurando um resultado pendente, `in_ready` permanece em zero.

## Funcionamento da FSM

A FSM controla o preenchimento do buffer, a leitura da ROM, a ativacao da MAC e o protocolo de saida.

### `STATE_FILL`

Estado de preenchimento e recepcao de amostras.

Neste estado:

- `in_ready = 1`;
- o circuito aceita uma amostra quando `in_valid && in_ready`;
- a amostra aceita e escrita no buffer circular;
- `out_valid = 0`;
- a MAC ainda nao gera resultado.

Durante as primeiras `N-1` amostras, a FSM apenas preenche o buffer. Quando a N-esima amostra e aceita, a janela de correlacao esta completa e a FSM avanca para `STATE_ROM_WAIT`.

### `STATE_ROM_WAIT`

Estado usado para lidar com a latencia inicial da ROM sincrona.

A ROM externa amostra `rom_addr` em uma borda de clock e disponibiliza `rom_data` somente depois dessa borda. Por isso, antes de multiplicar o primeiro termo, a FSM coloca:

```text
rom_addr = 0
```

e espera um ciclo.

Neste estado:

- `in_ready = 0`;
- `rom_addr = 0`, pedindo `h[0]`;
- `mac_start = 1`, limpando/iniciando a MAC;
- nenhum termo valido ainda e acumulado.

### `STATE_MAC_RUN`

Estado em que a correlacao e calculada.

Neste estado:

- `mac_valid = 1`;
- a MAC acumula um produto por ciclo;
- `buffer_rd_addr = term_count`;
- `rom_data` contem o coeficiente solicitado no ciclo anterior;
- `rom_addr` ja e atualizado para o proximo coeficiente.

Como a ROM tem 1 ciclo de latencia, a FSM trabalha em pipeline simples:

```text
termo 0: x[n]   * h[0]
termo 1: x[n-1] * h[1]
termo 2: x[n-2] * h[2]
...
termo 7: x[n-7] * h[7]
```

Quando o ultimo termo e acumulado, a FSM avanca para `STATE_CAPTURE`.

### `STATE_CAPTURE`

Estado de captura do resultado.

A MAC e registravel: no ultimo ciclo de acumulacao, o ultimo produto e somado no registrador interno da MAC. O resultado atualizado fica disponivel apos a borda de clock. Por isso existe um estado separado para copiar o resultado final para `out_data`.

Neste estado:

- `capture_result = 1`;
- `out_data` recebe `mac_result`;
- `in_ready = 0`;
- `out_valid` ainda nao precisa ser usado para handshake.

### `STATE_HOLD`

Estado de saida pendente.

Neste estado:

- `out_valid = 1`;
- `out_data` permanece estavel;
- `in_ready = 0`;
- a FSM espera `out_ready = 1`.

Quando o consumidor aceita o resultado com `out_valid && out_ready`, a FSM retorna para `STATE_FILL` e o detector fica pronto para aceitar a proxima amostra.

## Buffer Circular

O buffer armazena as ultimas `N` amostras. Ele usa um ponteiro de escrita circular chamado `wr_ptr`.

Quando uma amostra e aceita:

```text
mem[wr_ptr] <= in_data
wr_ptr <= proxima posicao circular
```

Depois de uma escrita, `wr_ptr` aponta para a proxima posicao livre, nao para a amostra mais recente. Portanto, a amostra mais recente esta na posicao anterior a `wr_ptr`.

Por isso o buffer nao usa `rd_addr` diretamente como endereco fisico da memoria. A FSM envia `rd_addr` como endereco logico:

```text
rd_addr = 0 -> amostra mais recente
rd_addr = 1 -> amostra anterior
rd_addr = 2 -> duas amostras atras
...
```

O buffer converte esse endereco logico para um endereco fisico usando `rd_index`:

```verilog
assign rd_index = (wr_ptr > rd_addr) ?
                  (wr_ptr - rd_addr - 1'b1) :
                  (wr_ptr + N_VALUE - rd_addr - 1'b1);
```

Assim:

```text
rd_index = endereco fisico real dentro de mem[]
rd_addr  = distancia logica em relacao a amostra mais recente
```

Exemplo para `N=8`: depois de 8 escritas, `wr_ptr` volta para zero.

```text
mem[0] = x0
mem[1] = x1
...
mem[7] = x7
wr_ptr = 0
```

Se a FSM pedir `rd_addr = 0`, ela quer a amostra mais recente, `x7`. O buffer calcula:

```text
rd_index = 0 + 8 - 0 - 1 = 7
```

Logo retorna `mem[7]`.

Se a FSM pedir `rd_addr = 1`, ela quer `x6`:

```text
rd_index = 0 + 8 - 1 - 1 = 6
```

Esse mapeamento garante que `h[0]` multiplica a amostra mais recente, `h[1]` multiplica a anterior e assim por diante.

## MAC

A MAC esta no arquivo `mac_param.v`.

Ela recebe:

- `a`: amostra signed do buffer;
- `b`: coeficiente signed da ROM;
- `start`: limpa o acumulador e inicia uma nova operacao;
- `valid`: indica que o par `a` e `b` deve ser acumulado.

A multiplicacao e signed:

```verilog
assign product = a * b;
```

O produto de duas entradas de 16 bits gera 32 bits. O acumulador tem largura:

```text
ACC_WIDTH = 2*DATA_WIDTH + clog2(N)
```

Para `DATA_WIDTH=16` e `N=8`:

```text
ACC_WIDTH = 32 + 3 = 35 bits
```

Isso evita overflow na soma dos `N` produtos, dentro da margem especificada pelo laboratorio.

A MAC acumula exatamente `N` termos. Ao acumular o ultimo termo, ela:

- desativa `busy`;
- ativa `done` por um ciclo;
- deixa `result` com o valor final da correlacao.

## ROM Externa

A ROM nao faz parte do bloco sintetizado. O detector apenas gera `rom_addr` e recebe `rom_data`.

No testbench, a ROM foi modelada como sincrona:

```verilog
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rom_data <= 0;
    end else begin
        rom_data <= coeff[rom_addr];
    end
end
```

Isso representa a latencia exigida na especificacao: o endereco e amostrado em uma borda de clock e o dado aparece depois dessa borda.

## Constraints SDC

O arquivo `constraint.sdc` converte a especificacao externa do laboratorio para constraints de setup.

Principais valores:

- clock de 100 MHz: periodo de 10 ns;
- clock transition: 0.10 ns;
- clock uncertainty de setup: 0.20 ns;
- atraso de entrada da fonte de amostras: `1.20 + 0.30 = 1.50 ns`;
- atraso de entrada da ROM: `1.40 + 0.20 = 1.60 ns`;
- atraso de saida para consumidor: `1.00 + 0.30 = 1.30 ns`;
- atraso de saida para ROM: `0.80 + 0.20 = 1.00 ns`;
- reset assincrono removido dos caminhos funcionais com `set_false_path`.

As cargas tambem sao separadas por interface:

- `0.020 pF` para `out_data`, `out_valid` e `in_ready`;
- `0.010 pF` para `rom_addr`.

## Simulacao

Para compilar e rodar o testbench com Icarus Verilog:

```bash
iverilog -Wall -g2012 -o /tmp/lab8_pattern_detector.vvp \
  pattern_detector_tb.v \
  pattern_detector.v \
  fsm.v \
  buffer.v \
  mac_param.v

vvp /tmp/lab8_pattern_detector.vvp
```

Saida esperada:

```text
TESTE OK
```

O testbench verifica:

- ausencia de resultado antes de preencher `N` amostras;
- resultado correto apos a N-esima amostra;
- multiplicacao signed;
- ordem correta da janela, com `h[0]` ligado a amostra mais recente;
- `in_ready = 0` durante processamento e resultado pendente;
- `out_valid` e `out_data` estaveis enquanto `out_ready = 0`.
