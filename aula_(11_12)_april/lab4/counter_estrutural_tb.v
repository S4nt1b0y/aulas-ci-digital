`timescale 1ns/1ps

module counter_estrutural_tb;

    // Entradas
    reg clk_i;
    reg rst_i;

    // Saída
    wire [23:0] counter_o;

    // DUT (Device Under Test)
    counter_estrutural dut (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .counter_o(counter_o)
    );

    // Geração de clock (50MHz simulado)
    always #5 clk_i = ~clk_i;

    initial begin
        // Inicialização
        clk_i = 0;
        rst_i = 1;

        // Monitoramento
        $monitor("clk=%0b | rst=%b | counter=%b",
                  clk_i, rst_i, counter_o);

        // Reset ativo
        #20;
        rst_i = 0;

        // Rodar simulação por um tempo suficiente
        #10000000;

        // Finaliza
        $finish;
    end

    // Dump de waveform (opcional)
    initial begin
        $dumpfile("counter_estrutural_tb.vcd");
        $dumpvars(0, counter_estrutural_tb);
    end

endmodule