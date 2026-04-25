`timescale 1ns/1ps

module datapath_tb;

    parameter WIDTH = 4;

    reg clk;
    reg rst;
    reg [WIDTH-1:0] datain;
    reg [2:0] opcode;
    reg sel_regfile_input;
    reg [1:0] regfile_addr;
    reg sel_isOperand_A;
    reg write_enable;

    wire [WIDTH-1:0] alu_result;

    // Instancia o DUT
    datapath #(WIDTH) dut (
        .clk(clk),
        .rst(rst),
        .datain(datain),
        .opcode(opcode),
        .sel_regfile_input(sel_regfile_input),
        .regfile_addr(regfile_addr),
        .sel_isOperand_A(sel_isOperand_A),
        .write_enable(write_enable),
        .alu_result(alu_result)
    );

    // Clock
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        write_enable = 0;
        sel_regfile_input = 0;
        sel_isOperand_A = 0;
        datain = 0;
        opcode = 0;
        regfile_addr = 0;

        #10;
        rst = 0;

        //----------------------------------------
        // 1. Preencher o register file
        //----------------------------------------
        $display("=== Preenchendo register file ===");

        sel_regfile_input = 0; // usa datain

        write_enable = 1;

        // Reg 0 = 3
        regfile_addr = 2'b00;
        datain = 4'd3;
        #10;

        // Reg 1 = 5
        regfile_addr = 2'b01;
        datain = 4'd5;
        #10;

        // Reg 2 = 2
        regfile_addr = 2'b10;
        datain = 4'd2;
        #10;

        // Reg 3 = 7
        regfile_addr = 2'b11;
        datain = 4'd7;
        #10;

        write_enable = 0;

        //----------------------------------------
        // 2. Carregar operandos A e B
        //----------------------------------------
        $display("=== Carregando operandos ===");

        // Carrega A = Reg0
        regfile_addr = 2'b00;
        sel_isOperand_A = 0;
        #10;

        // Carrega B = Reg1
        regfile_addr = 2'b01;
        sel_isOperand_A = 1;
        #10;

        //----------------------------------------
        // 3. Executar operação da ULA e Escrever resultado no regfile
        //----------------------------------------
        $display("=== Operação ULA ===");

        opcode = 3'b100; // exemplo: soma
        sel_regfile_input = 1; // agora usa resultado da ULA
        write_enable = 1;
        regfile_addr = 2'b10; // sobrescreve Reg2
        #10;

        $display("Resultado ULA = %d", alu_result);

        $display("=== Escrevendo resultado no regfile ===");

        #10;
        write_enable = 0;

        //----------------------------------------
        // 5. Nova rodada usando valor atualizado
        //----------------------------------------
        $display("=== Segunda rodada ===");

        // A = Reg2 (novo valor)
        regfile_addr = 2'b10;
        sel_isOperand_A = 0;
        #10;

        // B = Reg3
        regfile_addr = 2'b11;
        sel_isOperand_A = 1;
        #10;

        opcode = 3'b100; // soma novamente
        #10;

        $display("Resultado ULA (rodada 2) = %d", alu_result);

        //----------------------------------------
        // 6. Checagem simples
        //----------------------------------------
        if (alu_result == 4'd7 ) begin
            $display("PASSOU TESTE FINAL");
        end
        $stop;
    end

endmodule