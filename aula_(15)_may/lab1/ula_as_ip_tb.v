module ula_as_ip_tb;

parameter WIDTH = 8;

reg clk;
reg rst;
reg request_valid;
reg [WIDTH-1:0] A;
reg [WIDTH-1:0] B;
reg [2:0] opcode;
wire [WIDTH-1:0] ip_result;
wire ip_valid;
wire ip_ready;

alu_as_ip #(
 .WIDTH(WIDTH)
)
DUT (

 .clk(clk),
 .rst(rst),
 .request_valid(request_valid),
 .A(A),
 .B(B),
 .opcode(opcode),
 .ip_result(ip_result),
 .ip_valid(ip_valid),
 .ip_ready(ip_ready)
);

always #5 clk = ~clk;

initial begin

 clk = 0;
 rst = 1;
 request_valid = 0;
#10;
request_valid = 1;
 A = 7;
 B = 3;
 opcode = 0;
 #10;

 
 $dumpfile("wave.vcd");

 $dumpvars(0, tb_alu_top);

 $finish;

end


always @(posedge clk) begin

 $display(
 "TIME=%0t | READY=%b | VALID=%b | REQ=%b | ENABLE=%b | RESULT=%d",
 $time,
 ip_ready,
 ip_valid,
 request_valid,
 DUT.enable_alu,
 ip_result
 );

end

endmodule