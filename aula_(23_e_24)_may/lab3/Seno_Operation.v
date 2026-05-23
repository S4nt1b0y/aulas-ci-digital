module Seno_Operation (
    input wire [7:0] phase,
    output [15:0] seno
 );

    wire [3:0] index;

    Seno_Decoder decoder(
        .phase(phase),
        .lut_index(index)
    );

    LUT_Seno lut(
        .address(index), 
        .seno(seno) 
    );

endmodule