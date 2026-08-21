// Modulo CSA parametrizavel
module parameterized_csa #(parameter WIDTH = 4) (
    input  [WIDTH-1:0] A,
    input  [WIDTH-1:0] B,
    input  [WIDTH-1:0] Cin,
    output [WIDTH-1:0] Sum,
    output [WIDTH-1:0] Cout
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : CSA_BITS
            assign Sum[i] = A[i] ^ B[i] ^ Cin[i];
            assign Cout[i] = (A[i] & B[i]) | (B[i] & Cin[i]) | (A[i] & Cin[i]);
        end
    endgenerate
endmodule