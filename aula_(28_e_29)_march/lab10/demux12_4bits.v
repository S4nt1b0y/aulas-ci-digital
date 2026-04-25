module demux1x2_4bits (
    input [3:0] in,    // Entrada de 4 bits
    input sel,          // Sinal de seleção (1 bit)
    output reg [3:0] out0,  // Saída 0 (4 bits)
    output reg [3:0] out1   // Saída 1 (4 bits)
);
    always @(*) begin
        // Inicializa as saídas para 0
        out0 = 4'b0000;
        out1 = 4'b0000;
        // Direciona a entrada para a saída selecionada
        case (sel)
            1'b0: out0 = in;  // Se sel = 0, a saída 0 recebe o valor de in
            1'b1: out1 = in;  // Se sel = 1, a saída 1 recebe o valor de in
            default: begin
                out0 = 4'b0000;
                out1 = 4'b0000;
            end
        endcase
    end
endmodule
