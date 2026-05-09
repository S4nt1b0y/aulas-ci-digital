module top_tb();

    reg [4:0] endereco_saida;
    reg we_resultado;
    reg [4:0] enderecoA;
    reg [4:0] enderecoB;
    reg clk;
    reg [7:0] dado_in;
    reg we_mem_in;
    wire [7:0] saida;
    wire [7:0] sdadoA;
    wire [7:0] sdadoB;
    wire [7:0] s_ula;
    reg cs;
    reg [2:0] opcode;
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end



    top dut(
        .endereco_saida(endereco_saida),
        .we_resultado(we_resultado),
        .enderecoA(enderecoA),
        .enderecoB(enderecoB),
        .clk(clk),
        .cs(cs),
        .dado_in(dado_in),
        .we_mem_in(we_mem_in),
        .opcode(opcode),
        .saida(saida),
        .sdadoA(sdadoA),
        .sdadoB(sdadoB),
        .s_ula(s_ula)
    );

    initial begin
        $monitor(
            "T=%0t | A=%d B=%d | dadoA=%d dadoB=%d | opcode=%d | ula=%d | saida=%d",
            $time,
            enderecoA,
            enderecoB,
            sdadoA,
            sdadoB,
            opcode,
            s_ula,
            saida
        );
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, top_tb);
    end

    initial begin

        //-------------------------------------
        // Inicialização
        //-------------------------------------
        endereco_saida = 0;
        cs = 1;
        opcode = 0;
        enderecoA      = 8'h08;
        enderecoB      = 8'h09;
        dado_in        = 8'h04;
        we_mem_in      = 0;
        we_resultado   = 0;
        #45;

        endereco_saida = 1;
        enderecoA      = 8'h00;
        we_mem_in      = 1;
        #20;

        enderecoB      = 8'h06;
        endereco_saida = 2;
        we_mem_in      = 0;
        dado_in        = 8'h05;
        #20;
        enderecoA      = 8'h01;
        #5
        we_mem_in      = 1;

        #15;
        we_mem_in      = 0;
        endereco_saida = 5;
        endereco_saida = 0;
        //-------------------------------------
        // Escreve 10 na RAM dual endereço 0
        //-------------------------------------
        @(posedge clk);
        enderecoA   = 5'd0;
        dado_in     = 8'd10;
        we_mem_in   = 1'b1;

        @(posedge clk);
        we_mem_in   = 1'b0;

        //-------------------------------------
        // Escreve 20 na RAM dual endereço 1
        //-------------------------------------
        @(posedge clk);
        enderecoA   = 5'd1;
        dado_in     = 8'd20;
        we_mem_in   = 1'b1;

        @(posedge clk);
        we_mem_in   = 1'b0;

        //-------------------------------------
        // Lê posições 0 e 1
        //-------------------------------------
        @(posedge clk);
        enderecoA = 5'd0;
        enderecoB = 5'd1;

        //-------------------------------------
        // Teste ALU
        //-------------------------------------
        // opcode = 0 -> soma
        //-------------------------------------
        opcode = 3'd0;

        #20;

        //-------------------------------------
        // Salva resultado da ALU
        //-------------------------------------
        @(posedge clk);
        endereco_saida = 5'd2;
        we_resultado   = 1'b1;

        @(posedge clk);
        we_resultado   = 1'b0;

        //-------------------------------------
        // Espera
        //-------------------------------------
        #50;

        $display("Fim da simulacao");
        $finish;

    end

endmodule