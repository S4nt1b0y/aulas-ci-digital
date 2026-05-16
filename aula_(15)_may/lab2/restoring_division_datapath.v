module restoring_division_datapath
#(
 parameter WIDTH = 8
)
(
 input wire clk,
 input wire rst,
 // controle
 input wire load,
 input wire [2:0] opcode,
 // operandos
 input wire [WIDTH-1:0] dividendo,
 input wire [WIDTH-1:0] divisor,
 // status para FSM
 output wire [WIDTH-1:0] a,
 output wire [WIDTH-1:0] n,
 // resultados
 output wire [WIDTH-1:0] quociente,
 output wire [WIDTH-1:0] resto

);
 // registradores internos
 reg [WIDTH-1:0] A; // resto
 reg [WIDTH-1:0] Q; // quociente/dividendo
 reg [WIDTH-1:0] M; // divisor
 reg [WIDTH-1:0] N; // contador

 // saídas

 assign a = A[WIDTH-1:0];
 assign n = N;
 assign quociente = Q;
 assign resto = A[WIDTH-1:0];


 // lógica principal

 always @(posedge clk or posedge rst)
 begin

 if(rst)
 begin

 A <= 0;
 Q <= 0;
 M <= 0;
 N <= 0;

 end

 else
 begin
 // LOAD
 if(load)
 begin
 A <= 0;
 Q <= dividendo;
 M <= divisor;
 N <= WIDTH;
 end

 // OPCODES

 case(opcode)
 // 000 -> NOP
 3'b000:
 begin
 end
 // 001 -> SHIFT LEFT AQ
 3'b001:
 begin
 A <= {A[WIDTH-1:0], Q[WIDTH-1]};
 Q <= {Q[WIDTH-2:0], 1'b0};
 end
 // 010 -> A = A + M
 3'b010:
 begin
 A <= A + {1'b0, M};
 end
 // 011 -> A = A - M
 3'b011:
 begin
 A <= A - {1'b0, M};
 end
 // 100 -> Q[0] = 1
 3'b100:
 begin
 Q[0] <= 1'b1;
 end
 // 101 -> Q[0] = 0
 3'b101:
 begin
 Q[0] <= 1'b0;
 end
 // 110 -> N = N - 1
 3'b110:
 begin
 N <= N - 1'b1;
 end
 endcase
 end
 end
endmodule