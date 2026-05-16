module alu_as_ip 
#(parameter WIDTH = 8)
(
 input clk,
 input rst,
 input request_valid,
 input [3:0] A,
 input [3:0] B,
 input [2:0] opcode,
 output [3:0] ip_result,
 output ip_valid,
 output ip_ready
);

 wire enable;
 wire [3:0] alu_result;

 ula_ctrl CTRL (
 .clk(clk),
 .rst(rst),
 .request_valid(request_valid),
 .alu_result(alu_result),
 .enable(enable),
 .ip_valid(ip_valid),
 .ip_result(ip_result),
 .ip_ready(ip_ready)
 );

 ula_datapath ULA (
 .A(A),
 .B(B),
 .enable(enable),
 .seletor(opcode),
 .resultado(alu_result)
 );

endmodule