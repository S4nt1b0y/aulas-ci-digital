`timescale 1ns/1ps

module top_tb;

    reg clk;
    reg inicia_operacao;
    reg rst;
    reg [4:0] endereco_ram_in;
    reg wr_en;
    reg start;
    reg cs_ram;
    reg [7:0] dado_usuario;
    reg [2:0] operacao_ula;
    reg [4:0] endereco_rom;
    reg cs_rom;

    wire fim;
    wire [7:0] resultado;
    wire [7:0] sdado_ram;
    wire [7:0] result_ula;
    wire [7:0] sdado_rom;

    top dut (
        .clk(clk),
        .inicia_operacao(inicia_operacao),
        .rst(rst),
        .endereco_ram_in(endereco_ram_in),
        .wr_en(wr_en),
        .start(start),
        .cs_ram(cs_ram),
        .dado_usuario(dado_usuario),
        .operacao_ula(operacao_ula),
        .endereco_rom(endereco_rom),
        .cs_rom(cs_rom),
        .fim(fim),
        .resultado(resultado),
        .sdado_ram(sdado_ram),
        .result_ula(result_ula),
        .sdado_rom(sdado_rom)
    );

    always #5 clk = ~clk;

    initial begin

        clk               = 0;
        rst               = 1;
        inicia_operacao   = 0;
        endereco_ram_in   = 0;
        wr_en             = 0;
        start             = 0;
        cs_ram            = 1;
        dado_usuario      = 0;
        operacao_ula      = 3'b000; 
        endereco_rom      = 0;
        cs_rom            = 1;


        #10;
        rst = 0;
        dado_usuario    = 8'd3;
        #1;
        wr_en           = 1;
        endereco_rom    = 5'd1;
        #14;
        dado_usuario    = 8'd4;
        wr_en = 0;
        #1;
        endereco_ram_in   = 1;
        #1;
        dado_usuario    = 8'd5;
        wr_en           = 1;
        #6;
        wr_en           = 0;
        #10;
        wr_en           = 1;
        endereco_ram_in   = 2;
        endereco_rom   = 06;
        #7;
        wr_en           = 0;
        endereco_ram_in   = 4;
        #3;
        wr_en           = 1;
    
        endereco_rom = 5'd1;


        start = 1;
        inicia_operacao = 1;

        start = 0;
        inicia_operacao = 0;

        #20;
        $finish;
    end

    // Monitor em tempo real
    initial begin
        $monitor("T=%0t | rst=%b | start=%b | RAM=%d | ROM=%d | ULA=%d | RESULT=%d | fim=%b",
                  $time,
                  rst,
                  start,
                  sdado_ram,
                  sdado_rom,
                  result_ula,
                  resultado,
                  fim);
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, top_tb);
    end

endmodule