module decoder_ram_4x1 (
    input wire [15:0] addr,
    output wire [9:0] effective_addr,
    output wire cs0,
    output wire cs1,
    output wire cs2,
    output wire cs3

);

assign effective_addr = addr[9:0];
assign cs0 = (addr >= 16'h0400 && addr <= 16'h07FF);
assign cs1 = (addr >= 16'h0800 && addr <= 16'h0BFF);
assign cs2 = (addr >= 16'h0C00 && addr <= 16'h0FFF);
assign cs3 = (addr >= 16'h1000 && addr <= 16'h13FF);



endmodule