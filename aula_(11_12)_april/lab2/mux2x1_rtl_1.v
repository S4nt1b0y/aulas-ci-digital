module mux2x1_rtl_1(
    input in1, in2, select,
    output out
);

    wire n_select, and1, and2;

    not g1(n_select, select);
    and g2(and1, select, in1);
    and g3(and2, n_select, in2);
    or  g4(out, and1, and2);

endmodule