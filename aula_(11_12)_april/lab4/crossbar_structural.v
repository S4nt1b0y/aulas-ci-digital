module crossbar_structural(
    input  in1,
    input  in2,
    input  select,
    output out1, 
    output out2
);

mux2x1_rtl_3 mux1 (
        .in1(in1),
        .in2(in2),
        .select(select),
        .out(out1)
    );

mux2x1_rtl_3 mux2 (
        .in1(in2),
        .in2(in1),
        .select(select),
        .out(out2)
    );

endmodule