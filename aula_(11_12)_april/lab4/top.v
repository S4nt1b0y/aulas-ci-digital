
module top 
#(
    parameter COUNTER_MAX = 16,
    parameter COUNTER_WIDTH = $clog2(COUNTER_MAX)
)(
    input  clk_i,
    input  rst_i,
    input [COUNTER_WIDTH-1:0] default_value,
    output reg out
);

wire [COUNTER_WIDTH-1:0] counter;
wire en;

counter #(.COUNTER_WIDTH(COUNTER_WIDTH)) counter_inst(
    .clk(clk_i),
    .rst(rst_i),
    .en_n(!en),
    .counter_o(counter)
);


compare #(.COUNTER_WIDTH(COUNTER_WIDTH)) compare_inst
(
    .default_value(default_value), 
    .counter_i(counter),
    .isEqual(en)
);

always @(posedge clk_i) begin
    out <= en;
end

endmodule