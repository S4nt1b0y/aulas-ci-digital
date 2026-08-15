// ===============================================
// Buffer circular
// ===============================================

module buffer 
#(
    parameter N = 8,
    parameter NLOG2 = $clog2(N)
)
(
    input wire       clk,
    input wire       rst,
    input wire       wr_en,     
    input wire [NLOG2-1:0] rd_addr,      
    input wire [N-1:0] data_in,     
    output reg [N-1:0] data_out

);

reg [N-1:0] mem [0:15];
reg [NLOG2-1:0] wr_ptr;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        wr_ptr  <= 0;
        mem <= '0;
    end
    else begin
        if(wr_en) begin
            mem[wr_ptr] <= data_in; 
            wr_ptr <= wr_ptr + 1;
        end
    end
end

assign data_out = mem[rd_addr]

endmodule