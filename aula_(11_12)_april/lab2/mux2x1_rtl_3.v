module mux2x1_rtl_3(
    input in1, in2, select,
    output out
);
  
    assign out = select ? in1 : in2;

endmodule