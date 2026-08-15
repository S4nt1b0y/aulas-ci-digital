module pattern_detector 
#(
    parameter N = 8,
    parameter NLOG2 = 3,
    parameter DATA_WIDTH = 16
)(
    input wire clk,
    input wire rst_n,
    input wire [DATA_WIDTH-1:0] in_data,
    input wire in_valid,
    output wire in_ready,
    output wire room_addr,
    input wire [DATA_WIDTH-1:0] room_data,
    output wire [((DATA_WIDTH*2)-1 + Nlog2):0] out_data,
    output wire out_valid,
    input wire out_ready
);

wire start_process;
wire rst_mac;

wire wr_en = in_valid && in_ready;
wire a_data;

buffer #(
    .N(N),
    .NLOG2(NLOG2)
) buffer_i (
    .clk(clk),
    .rst(rst_n),
    .wr_en(wr_en),     
    .rd_addr,      
    .data_in(in_data),  
    .data_out(a_data)
);

fsm #(
    .N(N),
    .NLOG2(NLOG2)
) fsm_i (
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(in_valid),
    .in_ready(in_ready),
    .room_addr(room_addr),
    .start_proccess(start_process),
    .rst_mac(rst_mac),
    .out_ready(out_ready)
);

mac_param #(
    .DATA_WIDTH(DATA_WIDTH),
    .NUM_TERMS(N)
) mac_i(
    .clk(clk),
    .rst_n(rst_mac),
    .start(start_process),
    .valid(),
    .a(a_data),
    .b(room_data),
    .busy,
    .done,
    .result()
);

endmodule