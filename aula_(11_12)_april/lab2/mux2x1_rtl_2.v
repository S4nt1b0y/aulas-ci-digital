module mux2x1_rtl_2(
    input in1, in2, select,
    output out
);

    wire n_select, and1, and2;

    assign n_select = ~select;
    assign and1 = in1 & select;
    assign and2 = in2 & n_select;
    assign or1 = and1 | and2;
    assign out = or1;

endmodule