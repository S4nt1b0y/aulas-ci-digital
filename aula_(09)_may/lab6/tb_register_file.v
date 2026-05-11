`timescale 1ns/1ps

module tb_register_file;

    // Parâmetros
    parameter DATA_WIDTH = 16;
    parameter ADDR_WIDTH = 3;
    parameter REG_COUNT  = 8;

    // Sinais do DUT
    reg                         clk;
    reg                         wr_en;
    reg  [ADDR_WIDTH-1:0]      wr_addr;
    reg  [DATA_WIDTH-1:0]      wr_data;
    reg  [ADDR_WIDTH-1:0]      rd_addr1;
    reg  [ADDR_WIDTH-1:0]      rd_addr2;

    wire [DATA_WIDTH-1:0]      rd_data1;
    wire [DATA_WIDTH-1:0]      rd_data2;

    // Instanciação do DUT
    register_file #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .REG_COUNT(REG_COUNT)
    ) dut (
        .clk(clk),
        .wr_en(wr_en),
        .wr_addr(wr_addr),
        .wr_data(wr_data),
        .rd_addr1(rd_addr1),
        .rd_addr2(rd_addr2),
        .rd_data1(rd_data1),
        .rd_data2(rd_data2)
    );

    // Clock de 10ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_register_file);
    end

    // Procedimento de teste
    initial begin

        // Inicialização
        wr_en    = 0;
        wr_addr  = 0;
        wr_data  = 0;
        rd_addr1 = 0;
        rd_addr2 = 0;

        // Aguarda alguns ciclos
        #20;

        $display("======================================");
        $display("TESTE 1 - Escrita no registrador x1");
        $display("======================================");

        // Escreve no registrador 1
        @(posedge clk);
        wr_en   <= 1;
        wr_addr <= 3'd1;
        wr_data <= 16'hAABB;

        @(posedge clk);
        wr_en <= 0;

        // Leitura
        rd_addr1 <= 3'd1;

        #2;

        $display("Registrador x1 = %h", rd_data1);

        if (rd_data1 == 16'hAABB)
            $display("TESTE 1 PASSOU\n");
        else
            $display("TESTE 1 FALHOU\n");

        // ------------------------------------------------

        $display("======================================");
        $display("TESTE 2 - Escrita no registrador x5");
        $display("======================================");

        @(posedge clk);
        wr_en   <= 1;
        wr_addr <= 3'd5;
        wr_data <= 16'h1234;

        @(posedge clk);
        wr_en <= 0;

        rd_addr1 <= 3'd5;

        #2;

        $display("Registrador x5 = %h", rd_data1);

        if (rd_data1 == 16'h1234)
            $display("TESTE 2 PASSOU\n");
        else
            $display("TESTE 2 FALHOU\n");

        // ------------------------------------------------

        $display("======================================");
        $display("TESTE 3 - Registrador x0 deve ser zero");
        $display("======================================");

        // Tentativa de escrita em x0
        @(posedge clk);
        wr_en   <= 1;
        wr_addr <= 3'd0;
        wr_data <= 16'hFFFF;

        @(posedge clk);
        wr_en <= 0;

        rd_addr1 <= 3'd0;

        #2;

        $display("Registrador x0 = %h", rd_data1);

        if (rd_data1 == 16'h0000)
            $display("TESTE 3 PASSOU\n");
        else
            $display("TESTE 3 FALHOU\n");

        // ------------------------------------------------

        $display("======================================");
        $display("TESTE 4 - Leitura simultânea");
        $display("======================================");

        rd_addr1 <= 3'd1;
        rd_addr2 <= 3'd5;

        #2;

        $display("rd_data1 (x1) = %h", rd_data1);
        $display("rd_data2 (x5) = %h", rd_data2);

        if ((rd_data1 == 16'hAABB) &&
            (rd_data2 == 16'h1234))
            $display("TESTE 4 PASSOU\n");
        else
            $display("TESTE 4 FALHOU\n");

        // ------------------------------------------------

        $display("======================================");
        $display("FIM DA SIMULACAO");
        $display("======================================");

        #20;
        $finish;
    end

endmodule