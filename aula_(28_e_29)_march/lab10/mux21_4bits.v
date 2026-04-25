module mux2x1_4bits (
    input  [3:0] in0,      //! Entrada 0 (4 bits)
    input  [3:0] in1,      //! Entrada 1 (4 bits)
    input  sel,            //! Sinal de seleção (1 bit)
    output [3:0] out       //! Saída do multiplexador (4 bits)
);
    // Atribuição combinacional
    assign out = (sel) ? in1 : in0; //! Seleciona in1 se sel = 1, caso contrário in0
endmodule
