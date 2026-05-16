
module restoring_division_top
#(
 parameter WIDTH = 8
)
(
 input wire clk,
 input wire rst,
 input wire start,
 input wire [WIDTH-1:0] dividendo,
 input wire [WIDTH-1:0] divisor,
 output wire [WIDTH-1:0] quociente,
 output wire [WIDTH-1:0] resto,
 output wire done,
 // flags
 output wire div_zero
);

 // sinais internos
 wire load;
 wire [2:0] opcode;
 wire [WIDTH-1:0] a;
 wire [WIDTH-1:0] n;

 // CONTROL UNIT

 restoring_division_ctrl #(.WIDTH(WIDTH)) CTRL
 (
 .clk(clk),
 .rst(rst),
 .start(start),
 .divisor(divisor),
 .dividendo(dividendo),
 .a(a),
 .n(n),
 .load(load),
 .opcode(opcode),
 .done(done),
 .invalid_operation(div_zero)
 );

 // DATAPATH

 restoring_division_datapath #( .WIDTH(WIDTH) ) DP (
 .clk(clk),
 .rst(rst),
 .load(load),
 .opcode(opcode),
 .dividendo(dividendo),
 .divisor(divisor),
 .a(a),
 .n(n),
 .quociente(quociente),
 .resto(resto)
 );

endmodule