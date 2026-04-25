module primitiva_and (out, in0, in1);
    input in0, in1;
    output out;

wire nand_out;

primitiva_nand u1 (
    .y(nand_out),
    .a(in0),
    .b(in1)
);

primitva_not u2 (
    .y(out),
    .a(nand_out)
);

endmodule