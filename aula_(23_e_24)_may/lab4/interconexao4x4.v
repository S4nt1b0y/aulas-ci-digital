module interconexao4x4(
    input  wire [7:0] in0, in1, in2, in3,
    output wire [7:0] out0, out1, out2, out3
);
    // Estágio 0
    wire [7:0] s0_out0, s0_out1, s0_out2, s0_out3;

    crossbar_2x2 stage0_sw0(
        .x0(in0), .x1(in1),
        .s(in0[7]), // bit mais significativo do destino
        .y0(s0_out0), .y1(s0_out1)
    );

    crossbar_2x2 stage0_sw1(
        .x0(in2), .x1(in3),
        .s(in2[7]),
        .y0(s0_out2), .y1(s0_out3)
    );

    // Estágio 1
    wire [7:0] s1_out0, s1_out1, s1_out2, s1_out3;

    crossbar_2x2 stage1_sw0(
        .x0(s0_out0), .x1(s0_out2),
        .s(s0_out0[6]), // segundo bit do destino
        .y0(s1_out0), .y1(s1_out1)
    );

    crossbar_2x2 stage1_sw1(
        .x0(s0_out1), .x1(s0_out3),
        .s(s0_out1[6]),
        .y0(s1_out2), .y1(s1_out3)
    );

    // Saidas
    assign out0 = s1_out0;
    assign out1 = s1_out1;
    assign out2 = s1_out2;
    assign out3 = s1_out3;
endmodule
