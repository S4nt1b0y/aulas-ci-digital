module mac_lab9_top (
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire valid,
    input wire [7:0] a,
    input wire [7:0] b,
    output wire busy,
    output wire done,
    output wire [26:0] result
);

mac_param #(
    .DATA_WIDTH(8),
    .NUM_TERMS(2048)
) dut (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .valid(valid),
    .a(a),
    .b(b),
    .busy(busy),
    .done(done),
    .result(result)
);

endmodule
