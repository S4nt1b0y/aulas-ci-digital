`timescale 1ns/1ps

module top_tb;

parameter COUNTER_MAX = 16;
localparam COUNTER_WIDTH = $clog2(COUNTER_MAX);

// sinais
reg clk;
reg rst;
reg [COUNTER_WIDTH-1:0] default_value;
wire out;

// instância do DUT
circuit12 #(
    .COUNTER_MAX(COUNTER_MAX)
) dut (
    .clk_i(clk),
    .rst_i(rst),
    .default_value(default_value),
    .out(out)
);

// clock: 10ns período
always #5 clk = ~clk;

// estímulos
initial begin
    // inicialização
    clk = 0;
    rst = 1;
    default_value = 5;

    // reset ativo
    #20;
    rst = 0;

    // roda um tempo
    #200;

    // muda valor de comparação
    default_value = 10;

    #200;

    // novo teste
    default_value = 3;

    #200;

    $finish;
end

// monitoramento
initial begin
    $dumpfile("circuit12.vcd");
    $dumpvars(0, circuit12_tb);
    
    $display("clk\trst\tcounter\tdefault\tout");
    $monitor("%b\t%b\t%d\t%d\t%b",
             clk, rst, dut.counter, default_value, out);
    
end


endmodule