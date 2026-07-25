module counter_tb;

reg clk, rst;
wire [7:0] count;


counter counter_i(
    .clk(clk),
    .rst(rst),
    .count(count)

);

initial begin
    clk = 0;
    rst = 0;
    #5;
    rst = 1;
    #5;
    forever #5 clk = ~clk;
end

initial begin
    #100;
    $finish;
end

initial begin
    forever #5 $display("%d", count);
end

endmodule