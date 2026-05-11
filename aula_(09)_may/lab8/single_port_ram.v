module single_port_ram(
 input wire     clk,
 input wire     we,
 input wire     cs,
 input wire [9:0] addr,
 input wire [7:0] din,
 output wire [7:0] dout
 );

 reg [7:0] mem [0:1023];
 reg [7:0] saida;

 assign dout = saida;

 integer i;

 initial begin
    saida = 8'd0;

    for(i = 0; i < 1024; i = i + 1) begin
        mem[i] = 8'd0;
    end

 end


 always @(posedge clk) begin
    if (cs) begin
        if (we) begin 
            mem[addr] <= din;
        end
        saida <= mem[addr];
    end
 end

endmodule