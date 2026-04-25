module register_4bits (
    input clk,        // Sinal de clock
    input reset,      // Sinal de reset (ativo em nível alto)
    input [3:0] d,    // Entrada de 4 bits
    output reg [3:0] q // Saída de 4 bits
);
    // Sempre que houver uma borda de subida no clock ou no reset
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            q <= 4'b0000; // Se reset estiver ativo, o registrador é limpo
        end else begin
            q <= d;      // Caso contrário, o registrador armazena o valor de d
        end
    end
endmodule
