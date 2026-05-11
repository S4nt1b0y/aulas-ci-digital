`timescale 1ns/1ps

module tb_decoder_ram;

reg clk;
reg we;
wire cs;

reg [15:0] addr;
reg [7:0] data_in;

wire [9:0] effective_addr;
wire [7:0] data_out;



decoder_ram uut (
    .addr(addr),
    .effective_addr(effective_addr),
    .cs(cs)
);

single_port_ram ram0 (
    .clk(clk),
    .we(we),
    .cs(cs),
    .addr(effective_addr),
    .din(data_in),
    .dout(data_out)
 );

always #5 clk = ~clk;

initial begin

    $dumpfile("wave.vcd");
    $dumpvars(0, tb_decoder_ram);


    clk = 0;
    we = 0;
    addr = 0;
    data_in = 0;

    $monitor("Tempo=%0t | WE=%b | ADDR=%h | data_in=%h | data_out=%h",
              $time,
              we,
              addr,
              data_in,
              data_out);

    we = 1;
    addr = 16'h0000;
    data_in  = 8'hFF;
    #10;

    addr = 16'h0001;
    data_in  = 8'hAA;
    #10;

    addr = 16'h03FF;
    data_in  = 8'h33;
    #10;

    we = 0;
    data_in  = 8'h44;
    addr = 16'h0000;
    #10;

    data_in  = 8'h55;
    addr = 16'h0001;
    #10;

    data_in  = 8'h66;
    addr = 16'h03FF;
    #10;

    we = 1;

    addr = 16'h0400;
    data_in  = 8'h55;
    #10;

    we = 0;
    data_in  = 8'h77;
    addr = 16'h0350;
    #10;

    $display(" FIM DA SIMULACAO ");

    $finish;

end

endmodule