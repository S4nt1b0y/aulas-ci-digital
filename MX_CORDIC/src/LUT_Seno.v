module LUT_Seno (
    input [3:0] address, // Endereco de entrada (0 a 9)
    output [15:0] seno // Valor do seno em formato Q1.15
);

reg [15:0] memoria [0:9]; // Memoria bidimensional de 10 posicoes de 16 bits

initial begin
    memoria[0] = 16'h0000; // 0 graus
    memoria[1] = 16'h1639; // 10 graus
    memoria[2] = 16'h2BC7; // 20 graus
    memoria[3] = 16'h4000; // 30 graus
    memoria[4] = 16'h5247; // 40 graus
    memoria[5] = 16'h620C; // 50 graus
    memoria[6] = 16'h6ED9; // 60 graus
    memoria[7] = 16'h7848; // 70 graus
    memoria[8] = 16'h7E0E; // 80 graus
    memoria[9] = 16'h8000; // 90 graus
end

    assign seno = memoria[address]; // Atribui o valor do seno baseado no endereco


endmodule