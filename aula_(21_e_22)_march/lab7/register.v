module register
#(
    parameter WIDTH = 8
)
(
    input wire clk,
    input wire [WIDTH-1:0] data_in,
    input wire load,
    input wire rst,
    output reg [WIDTH-1:0] data_out
);

always @(posedge clk) begin
    if(rst)begin
        data_out = {WIDTH{1'b0}};
    end else begin
        data_out = data_out;
        if(load) begin
            data_out = data_in;
        end
    end
end

endmodule