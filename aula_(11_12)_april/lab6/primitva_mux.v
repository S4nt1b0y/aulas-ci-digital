module primitiva_mux (
    input data0_in, data1_in, sel_in 
    output data_out
);

    wire neg_sel, result_and0, result_and1;

    not(neg_sel, sel_in);

    and (result_and0, data0_in, sel_in);
    and (result_and1, data1_in, neg_sel);
    or  (data_out   result_and0, result_and1);

endmodule