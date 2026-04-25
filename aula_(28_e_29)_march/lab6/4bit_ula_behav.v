module ula (
    input  [3:0] A,             // Operando A
    input  [3:0] B,             // Operando B
    input  [2:0] seletor,       // Sinal de seleção (3 bits)
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
            3'b000: resultado = A & B;       // Operação AND
            3'b001: resultado = A | B;       // Operação OR
            3'b010: resultado = ~A;          // Operação NOT (aplica-se apenas ao operando A)
            3'b011: resultado = ~(A & B);    // Operação NAND
            3'b100: begin
                {C, resultado} = A + B;
                Z = (resultado == 4'b0);
                N = (resultado[3]);
                C = (~A[3] && ~B[3] && resultado[3]);
                V = (A[3] == B[3]) && (resultado[3] != A[3]);
            end
            3'b101: begin
                {C, resultado} = A - B;
                Z = (resultado == 4'b0);
                N = (resultado[3]);
                V = (A[3] != B[3]) && (resultado[3] != A[3]);
            end
            3'b110: resultado = A << (B > 4 ? 4 : B );       // LSL
            3'b111: resultado = A >> (B > 4 ? 4 : B );       // LSR
            default: resultado = 4'b0000;    // Operação padrão (zero)
        endcase
        
    end

endmodule
