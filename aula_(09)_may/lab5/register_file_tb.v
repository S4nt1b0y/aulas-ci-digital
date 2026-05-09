`timescale 1ns/1ps
module register_file_tb();

localparam DATA_WIDTH = 8;
localparam ADDR_WIDTH = 2;
localparam REG_COUNT = 4;

reg clk, wr_en;

reg [DATA_WIDTH-1:0] wr_data;
wire [DATA_WIDTH-1:0] rd_data1;
wire [DATA_WIDTH-1:0] rd_data2;
wire wr_ack;
reg [ADDR_WIDTH-1:0] wr_addr;
reg [ADDR_WIDTH-1:0] rd_addr1;
reg [ADDR_WIDTH-1:0] rd_addr2;

register_file #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH),
    .REG_COUNT(REG_COUNT)
) register_file_i
(
    .clk(clk),
    .wr_en(wr_en),
    .wr_addr(wr_addr),
    .wr_data(wr_data),
    .rd_addr1(rd_addr1),
    .rd_addr2(rd_addr2),
    .rd_data1(rd_data1),
    .rd_data2(rd_data2),
    .wr_ack(wr_ack) //nunca usado
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    rd_addr1 = 2'd0;
    rd_addr2 = 2'd0;
    wr_en = 1'b0;
    wr_addr = 2'd0;
    wr_data = 8'h0;
    #10;
    //Escrever o valor 8’hAA nos quatro registros.
    @(negedge clk);
    wr_data = 8'hAA;
    wr_en = 1'b1;
    wr_addr = 2'd0;

    @(negedge clk);
    wr_addr = 2'd1;
    @(negedge clk);
    wr_addr = 2'd2;
    @(negedge clk);
    wr_addr = 2'd3;
    @(negedge clk);
    wr_en = 1'b0;
    //Ler registro[0] na porta 1, ler registro[1] na porta 2,
    rd_addr1 = 2'd0;
    rd_addr2 = 2'd1;
    @(negedge clk);
    // ler registro[2] na porta 1 e ler registro[3] na porta2.
    rd_addr1 = 2'd2;
    rd_addr2 = 2'd3;
    @(negedge clk);

    //Escrever o valor 8’h55 no registro[0], ler o registro[0] nas duas portas.
    wr_data = 8'h55;
    wr_en = 1'b1;
    wr_addr = 2'd0;
    @(negedge clk);
    wr_en = 1'b0;
    rd_addr1 = 2'd0;
    rd_addr2 = 2'd0;
    @(negedge clk);

    //Escrever o valor 8’hFF no registro[1], ler o registro[1] nas duas portas.
    wr_data = 8'hFF;
    wr_en = 1'b1;
    wr_addr = 2'd1;
    @(negedge clk);
    wr_en = 1'b0;
    rd_addr1 = 2'd1;
    rd_addr2 = 2'd1;
    @(negedge clk);
    //Escrever o valor 8’h22 no registro[2], ler o registro[2] nas duas portas.
    wr_data = 8'h22;
    wr_en = 1'b1;
    wr_addr = 2'd2;
    @(negedge clk);
    wr_en = 1'b0;
    rd_addr1 = 2'd2;
    rd_addr2 = 2'd2;
    @(negedge clk);
    //Escrever o valor 8’hBF no registro[3], ler o registro[3] nas duas portas.
    wr_data = 8'hBF;
    wr_en = 1'b1;
    wr_addr = 2'd3;
    @(negedge clk);
    wr_en = 1'b0;
    rd_addr1 = 2'd3;
    rd_addr2 = 2'd3;
    @(negedge clk);
    $stop;
    $finish;
end


endmodule