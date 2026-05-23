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

 always @(posedge clk or posedge rst) begin
    if(rst) begin
        A <= 0;
        Q <= 0;
        M <= 0;
        N <= 0;

    end else begin
    // LOAD
    if(load) begin
        A = 0;
        Q = dividendo;
        M = divisor;
        N = WIDTH;
    end else begin 
        case(opcode)
            3'b001:begin
                A = {A[WIDTH-1:0], Q[WIDTH-1]};
                Q = {Q[WIDTH-2:0], 1'b0};
            end
            3'b010: A = A + {1'b0, M};
            3'b011: A = A - {1'b0, M};
            3'b100: Q[0] = 1'b1;
            3'b101: Q[0] = 1'b0;
            3'b110: N = N - 1'b1;
        endcase
    end
    end
end
 // OPCODES


 
endmodule