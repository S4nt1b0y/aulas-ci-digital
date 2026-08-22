`timescale 1ns/1ps

// ===============================================
// Buffer circular
// rd_addr = 0 retorna a amostra mais recente,
// rd_addr = 1 retorna a amostra anterior, e assim por diante.
// ===============================================

module buffer
#(
    parameter N = 8,
    parameter DATA_WIDTH = 16,
    parameter NLOG2 = (N <= 1) ? 1 : $clog2(N)
)
(
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire                         wr_en,
    input  wire [NLOG2-1:0]             rd_addr,
    input  wire signed [DATA_WIDTH-1:0] data_in,
    output wire signed [DATA_WIDTH-1:0] data_out
);

reg signed [DATA_WIDTH-1:0] mem [0:N-1];
reg [NLOG2-1:0] wr_ptr;
wire [NLOG2-1:0] rd_index;
integer i;
localparam [NLOG2-1:0] N_VALUE = N;

assign rd_index = (wr_ptr > rd_addr) ? (wr_ptr - rd_addr - 1'b1) :
                                      (wr_ptr + N_VALUE - rd_addr - 1'b1);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wr_ptr <= {NLOG2{1'b0}};
        for (i = 0; i < N; i = i + 1) begin
            mem[i] <= {DATA_WIDTH{1'b0}};
        end
    end else if (wr_en) begin
        mem[wr_ptr] <= data_in;
        if (wr_ptr == N_VALUE - 1'b1) begin
            wr_ptr <= {NLOG2{1'b0}};
        end else begin
            wr_ptr <= wr_ptr + 1'b1;
        end
    end
end

assign data_out = mem[rd_index];

endmodule
