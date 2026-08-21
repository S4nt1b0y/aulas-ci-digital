module memory #(
parameter WIDTH = 8
) (
input clk, memoryWrite, memoryRead,
input [2*WIDTH-1:0] memoryWriteData,
input [WIDTH-1:0] memoryAddress,
output wire[2*WIDTH-1:0] memoryOutData
);

reg [2*WIDTH-1:0] mem [0:(1 << WIDTH) -1];

always @(posedge clk) begin
    if (memoryWrite) mem[memoryAddress] <= memoryWriteData;
end
assign memoryOutData = memoryRead ? mem[memoryAddress] : {WIDTH{1'b0}};
endmodule
