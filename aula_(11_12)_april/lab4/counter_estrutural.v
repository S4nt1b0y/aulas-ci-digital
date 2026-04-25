module counter_estrutural (
   input clk_i,
   input rst_i,
   output [23:0] counter_o
);

wire [11:0] counter_lower, counter_higher;

counter #(.COUNTER_WIDTH(12)) counter_inst1(
    .clk(clk_i),
    .rst(rst_i),
    .en_n(1'b1),
    .counter_o(counter_lower)
);

counter #(.COUNTER_WIDTH(12)) counter_inst2(
    .clk(counter_lower[11]),
    .rst(rst_i),
    .en_n(1'b1),
    .counter_o(counter_higher)
);

assign counter_o = {counter_higher, counter_lower};

endmodule