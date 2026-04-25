module memory #(
    parameter AWIDTH = 5,
    parameter DWIDTH = 8
)
(
    input wire clk,
    input wire [AWIDTH-1:0] addr,
    input wire wr,
    input wire rd,
    inout wire [DWIDTH-1:0] data
);

reg [DWIDTH-1:0] regbank [(1 << AWIDTH)-1:0];

assign data = (rd || !wr ) ? regbank[addr] : {DWIDTH{1'bz}};

always @( posedge clk) begin
    if(wr) begin
        regbank[addr] <= data;
    end
end



endmodule