`timescale 1ns/1ps

module memory_tb;

    reg clk;
    reg cs = 1;
    

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    reg  [3:0] rom_addr;
    wire [7:0] rom_data_out;

    rom ROM (
        .clk(clk),
        .addr(rom_addr),
        .data_out(rom_data_out)
    );

    reg         sp_we;
    reg  [4:0]  sp_addr;
    reg  [15:0] sp_data_in;
    wire [15:0] sp_data_out;

    ram_single RAM_SP (
        .clk(clk),
        .cs(cs),
        .we(sp_we),
        .addr(sp_addr),
        .data_in(sp_data_in),
        .data_out(sp_data_out)
    );

    reg        dp_we;
    reg [5:0]  dp_addr_wr;
    reg [7:0]  dp_data_wr;

    reg [5:0]  dp_addr_rd;
    wire [7:0] dp_data_rd;

    ram_dual RAM_DP (
        .clk(clk),
        .cs(cs),
        
        .we_a(dp_we),
        .addr_wr(dp_addr_wr),
        .data_wr(dp_data_wr),

        .addr_rd(dp_addr_rd),
        .data_rd(dp_data_rd)
    );

    // =====================================================
    // TESTES
    // =====================================================

    initial begin

        $display("\n========================================");
        $display("INICIO DA SIMULACAO");
        $display("========================================");

        // Inicialização geral
        rom_addr      = 0;

        sp_we         = 0;
        sp_addr       = 0;
        sp_data_in    = 0;

        dp_we       = 0;
        dp_addr_wr     = 0;
        dp_data_wr  = 0;
        dp_addr_rd     = 0;

        // Aguarda alguns ciclos
        #10;

        $display("\n========================================");
        $display("TESTE ROM 16x8");
        $display("========================================");

        rom_addr = 4'd0;
        #10;

        rom_addr = 4'd1;
        #10;

        rom_addr = 4'd5;
        #10;

        rom_addr = 4'd10;
        #10;

        rom_addr = 4'd15;
        #10;

        $display("\n========================================");
        $display("TESTE RAM SINGLE PORT 32x16");
        $display("========================================");

        // Escrita endereço 3
        sp_we      = 1;
        sp_addr    = 5'd3;
        sp_data_in = 16'd100;
        #10;

        // Escrita endereço 7
        sp_addr    = 5'd7;
        sp_data_in = 16'd200;
        #10;

        // Escrita endereço 10
        sp_addr    = 5'd10;
        sp_data_in = 16'd300;
        #10;

        // Desabilita escrita
        sp_we = 0;

        // Leitura endereço 3
        sp_addr = 5'd3;
        #10;

        // Leitura endereço 7
        sp_addr = 5'd7;
        #10;

        // Leitura endereço 10
        sp_addr = 5'd10;
        #10;

        // Persistência
        sp_addr = 5'd3;
        #10;

        $display("\n========================================");
        $display("TESTE RAM DUAL PORT 64x8");
        $display("========================================");

        // Escrita endereço 4
        dp_we      = 1;
        dp_addr_wr    = 6'd4;
        dp_data_wr = 8'd50;
        #10;

        // Escrita endereço 8
        dp_addr_wr    = 6'd8;
        dp_data_wr = 8'd100;
        #10;

        // Escrita endereço 12
        dp_addr_wr    = 6'd12;
        dp_data_wr = 8'd150;
        #10;

        // Finaliza escrita
        dp_we = 0;

        // Leitura endereço 4
        dp_addr_rd = 6'd4;
        #10;

        // Leitura endereço 8
        dp_addr_rd = 6'd8;
        #10;

        // Leitura endereço 12
        dp_addr_rd = 6'd12;
        #10;

        // Escrita e leitura simultânea
        dp_we      = 1;
        dp_addr_wr    = 6'd20;
        dp_data_wr = 8'd77;

        dp_addr_rd    = 6'd8;
        #10;

        // Leitura do novo valor
        dp_we   = 0;
        dp_addr_rd = 6'd20;
        #10;

        $display("\n========================================");
        $display("FIM DA SIMULACAO");
        $display("========================================");

        #20;
        $finish;

    end

    initial begin
        $monitor(
            "\nTempo=%0t\nROM -> addr=%d data=%d\nSP_RAM -> we=%b addr=%d in=%d out=%d\nDP_RAM -> we=%b addrA=%d inA=%d addrB=%d outB=%d\n",
            $time,

            rom_addr,
            rom_data_out,

            sp_we,
            sp_addr,
            sp_data_in,
            sp_data_out,

            dp_we,
            dp_addr_wr,
            dp_data_wr,
            dp_addr_rd,
            dp_data_rd
        );
    end

endmodule