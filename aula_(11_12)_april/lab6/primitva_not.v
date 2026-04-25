module primitva_not (
    output y,
    input a
);

pmos (y, 1'b1, a);
nmos (y, 1'b0, a);

endmodule