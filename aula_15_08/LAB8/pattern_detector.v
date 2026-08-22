`timescale 1ns/1ps

module pattern_detector
#(
    parameter N = 8,
    parameter DATA_WIDTH = 16,
    parameter NLOG2 = (N <= 1) ? 1 : $clog2(N),
    parameter ACC_WIDTH = (2 * DATA_WIDTH) + NLOG2
)
(
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire signed [DATA_WIDTH-1:0] in_data,
    input  wire                         in_valid,
    output wire                         in_ready,
    output wire [NLOG2-1:0]             rom_addr,
    input  wire signed [DATA_WIDTH-1:0] rom_data,
    output reg  signed [ACC_WIDTH-1:0]  out_data,
    output wire                         out_valid,
    input  wire                         out_ready
);

wire sample_accept;
wire [NLOG2-1:0] buffer_rd_addr;
wire mac_start;
wire mac_valid;
wire capture_result;
wire mac_busy;
wire mac_done;
wire signed [DATA_WIDTH-1:0] sample_data;
wire signed [ACC_WIDTH-1:0] mac_result;

assign sample_accept = in_valid && in_ready;

buffer #(
    .N(N),
    .DATA_WIDTH(DATA_WIDTH),
    .NLOG2(NLOG2)
) buffer_i (
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sample_accept),
    .rd_addr(buffer_rd_addr),
    .data_in(in_data),
    .data_out(sample_data)
);

fsm #(
    .N(N),
    .NLOG2(NLOG2)
) fsm_i (
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(in_valid),
    .out_ready(out_ready),
    .in_ready(in_ready),
    .out_valid(out_valid),
    .rom_addr(rom_addr),
    .buffer_rd_addr(buffer_rd_addr),
    .mac_start(mac_start),
    .mac_valid(mac_valid),
    .capture_result(capture_result)
);

mac_param #(
    .DATA_WIDTH(DATA_WIDTH),
    .NUM_TERMS(N),
    .ACC_WIDTH(ACC_WIDTH)
) mac_i (
    .clk(clk),
    .rst_n(rst_n),
    .start(mac_start),
    .valid(mac_valid),
    .a(sample_data),
    .b(rom_data),
    .busy(mac_busy),
    .done(mac_done),
    .result(mac_result)
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_data <= {ACC_WIDTH{1'b0}};
    end else if (capture_result && mac_done) begin
        out_data <= mac_result;
    end
end

endmodule
