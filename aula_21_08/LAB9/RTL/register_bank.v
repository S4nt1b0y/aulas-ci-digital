module register_bank #(
parameter WIDTH = 8
) (
input clk,
input rst,
input wr_en,
input [WIDTH-1:0] in,
output reg[WIDTH-1:0] out
);

always @(posedge clk, posedge rst) begin
    if (rst) out <= {WIDTH{1'b0}};
    else
        if (wr_en) out <= in;
end

endmodule
