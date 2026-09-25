module x3_longo (
    output reg [7:0] XPower ,
    input [7:0] X,
    input clk
);
reg [7:0] X1;

always @( posedge clk ) begin
    // Pipeline Stage 1
    X1 <= X;
    XPower <= X1 * X1 * X1;
end

endmodule