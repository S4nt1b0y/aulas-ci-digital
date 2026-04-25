module primitiva_nand (y, a, b);
    input a, b;
    output y;

    pmos (y, 1'b1, a);
    pmos (y, 1'b1, b);

    wire n1;
    nmos (n1, 1'b0, b);
    nmos (y, n1, a);

endmodule