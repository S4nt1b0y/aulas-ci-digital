module decoder_ram (
    input wire [15:0] addr,
    output wire [9:0] effective_addr,
    output wire cs
 );

 assign cs = (addr >= 16'h0000 && addr <= 16'h03FF);
 assign effective_addr = addr[9:0];

endmodule