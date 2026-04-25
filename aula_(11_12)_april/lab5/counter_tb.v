`timescale 1ns/1ps

module counter_tb;

parameter COUNTER_WIDTH = 16;

reg clk;
reg a_rst;
reg enable;
reg load;
reg mode;
reg [COUNTER_WIDTH-1:0] data_in;
wire [COUNTER_WIDTH-1:0] counter_o;

counter #(
    .COUNTER_WIDTH(COUNTER_WIDTH)
) uut (
    .clk(clk),
    .a_rst(a_rst),
    .enable(enable),
    .load(load),
    .mode(mode),
    .data_in(data_in),
    .counter_o(counter_o)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("counter.vcd");
    $dumpvars(0, counter_tb);

    // init
    clk = 0;
    a_rst = 1;
    enable = 0;
    load = 0;
    mode = 0;
    data_in = 0;

    // reset
    #10;
    a_rst = 0;

    // load valor inicial
    #10;
    load = 1;
    data_in = 16'd10;
    #10;
    load = 0;

    // contagem crescente
    enable = 1;
    mode = 1;
    #50;

    // contagem decrescente
    mode = 0;
    #50;

    // desabilita contador
    enable = 0;
    #20;

    // novo load
    load = 1;
    data_in = 16'd100;
    #10;
    load = 0;

    // conta de novo
    enable = 1;
    mode = 1;
    #50;

    $finish;
end

endmodule