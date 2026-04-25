module ula (
    input  [3:0] A,         // Operando A
    input  [3:0] B,         // Operando B
    input  [2:0] seletor,   // Sinal de seleção (3 bits)
    output reg [3:0] resultado // Resultado da operação
);
    always @(*) begin
        case (seletor)
            3'b000: resultado = A & B;       // Operação AND
            3'b001: resultado = A | B;       // Operação OR
            3'b010: resultado = ~A;          // Operação NOT (aplica-se apenas ao operando A)
            3'b011: resultado = ~(A & B);    // Operação NAND
            3'b100: resultado = A + B;       // Soma
            3'b101: resultado = A - B;       // Subtração
            3'b110: resultado = A << (B > 4 ? 4 : B );       // LSL
            3'b111: resultado = A >> (B > 4 ? 4 : B );       // LSR
            default: resultado = 4'b0000;    // Operação padrão (zero)
        endcase
    end
endmodule
