module ula (
    input  wire [3:0] A,             // Operando A
    input  wire [3:0] B,             // Operando B
    input  wire[3:0] seletor,       // Sinal de seleção (3 bits)
    input  wire carry_in,
    output reg [3:0] resultado, // Resultado da operação
    output reg C,               //Houve overflow
    output reg V,               //Houve underflow
    output reg Z,               //valor igual a zero
    output reg N,               //valor negativo
    output reg propagated_out,
    output reg generated_out
);

    localparam WIDTH = 4;

    wire [WIDTH-1:0] result_somador_cla;
    wire carry_out_somador_cla;

    wire [WIDTH-1:0] result_subtrator_cla;
    wire carry_out_subtrator_cla;
    wire propagated_sum;
    wire generated_sum;
    wire propagated_sub;
    wire generated_sub;


    somador_cla 
        #(.WIDTH(WIDTH))
        somador_cla_i(
        .operandA(A),
        .operandB(B),
        .carry_in(carry_in),
        .result(result_somador_cla),
        .carry_out(carry_out_somador_cla),
        .propagated(propagated_sum),
        .generated(generated_sum)
    );

    subtrator 
        #(.WIDTH(WIDTH))
        subtrator_cla_i(
        .operandA(A),
        .operandB(B),
        .carry_in(carry_in),
        .result(result_subtrator_cla),
        .carry_out(carry_out_subtrator_cla),
        .propagated(propagated_sub),
        .generated(generated_sub)
    );


    always @(*) begin
        C = 0;
        Z = 0;
        N = 0;
        V = 0;
        propagated_out = 0;
        generated_out = 0;
        case (seletor)
            4'b0000: resultado = A & B;       // Operação AND
            4'b0001: resultado = A | B;       // Operação OR
            4'b0010: resultado = ~A;          // Operação NOT (aplica-se apenas ao operando A)
            4'b0011: resultado = ~(A & B);    // Operação NAND
            4'b0100: begin
                resultado = result_somador_cla;
                C = carry_out_somador_cla;
                Z = (resultado == 4'b0);
                N = (resultado[3]);
                V = (A[3] == B[3]) && (resultado[3] != A[3]);
                propagated_out = propagated_sum;
                generated_out = generated_sum;
            end
            4'b0101: begin
                resultado = result_subtrator_cla;
                C = carry_out_subtrator_cla;
                Z = (resultado == 4'b0);
                N = (resultado[3]);
                V = (A[3] != B[3]) && (resultado[3] != A[3]);
                propagated_out = propagated_sub;
                generated_out = generated_sub;
            end
            4'b0110: resultado = A << (B > 4 ? 4 : B );       // LSL
            4'b0111: resultado = A >> (B > 4 ? 4 : B );       // LSR
            4'b1000: resultado = A ^ B;                       // XOR
            4'b1001: resultado = ~(A | B);                   // NOR
            default: resultado = 4'b0000;    // Operação padrão (zero)
        endcase
        
    end

endmodule
