`timescale 1ns/1ps

module sistema_interconexao4x4_tb;

    reg         clk;
    reg         rst;
    reg         load0, load1, load2, load3;
    reg  [7:0]  in_dado0, in_dado1, in_dado2, in_dado3;

    wire [7:0] out0, out1, out2, out3;

    sistema_interconexao4x4 dut (
        .clk(clk),
        .rst(rst),
        .load0(load0),
        .load1(load1),
        .load2(load2),
        .load3(load3),
        .in_dado0(in_dado0),
        .in_dado1(in_dado1),
        .in_dado2(in_dado2),
        .in_dado3(in_dado3),
        .out0(out0),
        .out1(out1),
        .out2(out2),
        .out3(out3)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        // Inicialização
        rst = 1;

        load0 = 0;
        load1 = 0;
        load2 = 0;
        load3 = 0;

        in_dado0 = 8'h00;
        in_dado1 = 8'h00;
        in_dado2 = 8'h00;
        in_dado3 = 8'h00;

        // Reset
        #20;
        rst = 0;

        // =====================================================
        // TESTE 1 - Cada entrada para uma saída diferente
        // =====================================================

        #10;
        load0 = 1; in_dado0 = 8'b00_000001; // entrada0 -> saída0
        load1 = 1; in_dado1 = 8'b01_000010; // entrada1 -> saída1
        load2 = 1; in_dado2 = 8'b10_000011; // entrada2 -> saída2
        load3 = 1; in_dado3 = 8'b11_000100; // entrada3 -> saída3

        #10;
        load0 = 0;
        load1 = 0;
        load2 = 0;
        load3 = 0;

        // Aguarda processamento
        #40;

        // =====================================================
        // TESTE 2 - Conflito:
        // Todas as entradas solicitam a MESMA saída (out2)
        // =====================================================

        #10;
        load0 = 1; in_dado0 = 8'b10_101010; // prioridade maior
        load1 = 1; in_dado1 = 8'b10_111100;
        load2 = 1; in_dado2 = 8'b10_001111;
        load3 = 1; in_dado3 = 8'b10_110011;

        #10;
        load0 = 0;
        load1 = 0;
        load2 = 0;
        load3 = 0;

        // Aguarda arbitragem
        #60;

        // =====================================================
        // TESTE 3 - Dois conflitos simultâneos
        // Entradas 0 e 1 -> out1
        // Entradas 2 e 3 -> out3
        // =====================================================

        #10;
        load0 = 1; in_dado0 = 8'b01_000111;
        load1 = 1; in_dado1 = 8'b01_111000;

        load2 = 1; in_dado2 = 8'b11_101010;
        load3 = 1; in_dado3 = 8'b11_010101;

        #10;
        load0 = 0;
        load1 = 0;
        load2 = 0;
        load3 = 0;

        #60;

        // =====================================================
        // TESTE 4 - Requisições sequenciais
        // =====================================================

        #10;
        load0 = 1; in_dado0 = 8'b00_111111;
        #10 load0 = 0;

        #20;
        load1 = 1; in_dado1 = 8'b10_000001;
        #10 load1 = 0;

        #20;
        load2 = 1; in_dado2 = 8'b01_111000;
        #10 load2 = 0;

        #20;
        load3 = 1; in_dado3 = 8'b11_101101;
        #10 load3 = 0;

        #80;

        $finish;
    end

endmodule