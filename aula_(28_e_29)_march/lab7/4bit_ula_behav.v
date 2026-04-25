module ula (
    input  [3:0] A,             // Operando A
    input  [3:0] B,             // Operando B
    input  [3:0] seletor,       // Sinal de seleção (3 bits)
    output reg [3:0] resultado, // Resultado da operação
    output reg C,               //Houve overflow
    output reg V,               //Houve underflow
    output reg Z,               //valor igual a zero
    output reg N               //valor negativo
);

    always @(*) begin
        C = 0;
        Z = 0;
        N = 0;
        V = 0;
        case (seletor)
            4'b0000: resultado = A & B;       // Operação AND
            4'b0001: resultado = A | B;       // Operação OR
            4'b0010: resultado = ~A;          // Operação NOT (aplica-se apenas ao operando A)
            4'b0011: resultado = ~(A & B);    // Operação NAND
            4'b0100: begin
                {C, resultado} = A + B;
                Z = (resultado == 4'b0);
                N = (resultado[3]);
                C = (~A[3] && ~B[3] && resultado[3]);
                V = (A[3] == B[3]) && (resultado[3] != A[3]);
            end
            4'b0101: begin
                {C, resultado} = A - B;
                Z = (resultado == 4'b0);
                N = (resultado[3]);
                V = (A[3] != B[3]) && (resultado[3] != A[3]);
            end
            4'b0110: resultado = A << (B > 4 ? 4 : B );       // LSL
            4'b0111: resultado = A >> (B > 4 ? 4 : B );       // LSR
            4'b1000: resultado = A ^ B;                       // XOR
            4'b1001: resultado = ~(A | B);                   // NOR
            default: resultado = 4'b0000;    // Operação padrão (zero)
        endcase
        
    end

endmodule
