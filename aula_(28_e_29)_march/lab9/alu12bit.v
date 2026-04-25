module alu12bit (
    input  wire [11:0] A,             // Operando A
    input  wire [11:0] B,             // Operando B
    input  wire [3:0] seletor,       // Sinal de seleção (3 bits)
    input  wire carry_in,
    output wire [11:0] resultado, // Resultado da operação
    output wire C,               //Houve overflow
    output wire V,               //Houve underflow
    output wire Z,               //valor igual a zero
    output wire N,               //valor negativo
    output wire propagated_out,
    output wire generated_out
);


    wire [3:0] result_low, result_mid, result_high;

    wire P0, G0, P1, G1, P2, G2;

    wire C4, C8;
 

    ula ula_lower(
        .A(A[3:0]),
        .B(B[3:0]),
        .seletor(seletor),
        .carry_in(carry_in),
        .resultado(result_low),
        .C(C4),
        .propagated_out(P0),
        .generated_out(G0)
    );

    ula ula_mid(
        .A(A[7:4]),
        .B(B[7:4]),
        .seletor(seletor),
        .carry_in(C4),
        .C(C8),
        .resultado(result_mid),
        .propagated_out(P1),
        .generated_out(G1)
    );

    ula ula_higher(
        .A(A[11:8]),
        .B(B[11:8]),
        .seletor(seletor),
        .carry_in(C8),
        .resultado(result_high),
        .C(C),
        .V(V),
        .N(N),
        .propagated_out(P2),
        .generated_out(G2)
    );

    assign resultado = {result_high, result_mid, result_low};

     // Flags
    assign Z = (resultado == 12'b0);

    // P e G do bloco inteiro (8 bits)
    assign propagated_out = P2 & P1 & P0;
    assign generated_out  = G2 | (P2 & G1) | (P2 & P1 & G0);
    
endmodule