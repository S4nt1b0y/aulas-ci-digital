`timescale 1ns/1ps

module flipflop_udp_tb;

// sinais
reg d;
reg clk;
reg rst;
wire q;

// instância do UDP
flipflop_udp uut (q, rst, clk, d);

// clock: 10ns
always #5 clk = ~clk;

initial begin
    $dumpfile("flipflop_udp_tb.vcd");
    $dumpvars(0, flipflop_udp_tb);

    // inicialização
    clk = 0;
    d   = 0;
    rst = 0;

    // reset
    #3 rst = 1;
    #10 rst = 0;

    // teste: d = 1
    #7 d = 1;
    #20;

    // teste: d = 0
    d = 0;
    #20;

    // teste: d indefinido
    d = 1'b0;
    #20;

    // múltiplas transições
    d = 1;
    #10;
    d = 0;
    #10;
    d = 1;
    #10;

    // novo reset no meio
    rst = 1;
    #10;
    rst = 0;

    // mais estímulos
    d = 1;
    #20;
    d = 0;
    #20;

    $finish;
end

// monitoramento
initial begin
    $monitor("Time=%0t | rst=%b clk=%b d=%b | q=%b",
              $time, rst, clk, d, q);
end

endmodule