module crossbar_2x2 (  // Exemplo com Barramentos de 8 bits
input wire [7:0] x0,   // Entrada 1
input wire [7:0] x1,   // Entrada 2
input wire s,          // Sinal de controle (select)
output wire [7:0] y0,  // Saída 1
output wire [7:0] y1  // Saída 2
);
 // Implementação das saídas usando multiplexadores 2 para 1
 // Se s = 0, conecta x0 a y0; se s = 1, conecta x1 a y0 
assign y0 = (s == 0) ? x0 : x1; 
// Se s = 0, conecta x1 a y1, se s = 1, conecta x0 a y1
assign y1 = (s == 0) ? x1 : x0;

endmodule
