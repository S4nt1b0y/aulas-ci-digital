`timescale 1ns/1ps

module tb_fifo;


reg clk;
reg rst;
reg push_i;
reg pop_i;
reg [7:0] data_in;
wire [7:0] data_out;
wire empty;
wire full;
wire error;

fifo dut (   
    .clk(clk),   
    .rst(rst),  
    .push_i(push_i),  
    .pop_i(pop_i),  
    .data_in(data_in),
    .data_out(data_out),  
    .empty(empty),  
    .full(full),  
    .error(error)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("fifo_tb.vcd");
    $dumpvars(0, tb_fifo);

    clk = 0;
    rst = 1;
    push_i = 0;
    pop_i = 0;
    data_in = 0;

    #20;
    rst = 0;

    $display("==========================================");
    $display(" TESTE");
    $display("==========================================");

    $display("Tempo\tWR\tRD\tDIN\tDOUT\tEMPTY\tFULL\tERROR");

    $monitor("%0t\t%b\t%b\t%0d\t%0d\t%b\t%b\t%b",
             $time,
             push_i,
             pop_i,
             data_in,
             data_out,
             empty,
             full,
             error);

    $display("\n--- TESTE EMPTY ---");

    #10;
    pop_i = 1;

    #10;
    pop_i = 0;

    $display("\n--- TESTE ESCRITA ---");

    #10;

    push_i = 1;
    data_in = 8'd00; #10;
    data_in = 8'd01; #10;
    data_in = 8'd02; #10;
    data_in = 8'd04; #10;

    push_i = 0;

    $display("\n--- TESTE LEITURA ---");

    #10;
    pop_i = 1;

    #40;
    pop_i = 0;

    $display("\n--- TESTE signal FULL ---");

    #10;

    push_i = 1;
    data_in = 8'd1;  #10;
    data_in = 8'd2;  #10;
    data_in = 8'd3;  #10;
    data_in = 8'd4;  #10;
    data_in = 8'd5;  #10;
    data_in = 8'd6;  #10;
    data_in = 8'd7;  #10;
    data_in = 8'd8;  #10;
    data_in = 8'd9;  #10;
    data_in = 8'd10; #10;
    data_in = 8'd11; #10;
    data_in = 8'd12; #10;
    data_in = 8'd13; #10;
    data_in = 8'd14; #10;
    data_in = 8'd15; #10;
    data_in = 8'd16; #10;

    push_i = 0;

    $display(" FIM DA SIMULACAO ");

    $finish;

end

endmodule