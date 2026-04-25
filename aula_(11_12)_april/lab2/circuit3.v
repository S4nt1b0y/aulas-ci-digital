module circuit3(
    input wire a_i, b_i, c_i, d_i,
    output wire s_o
);
  
    assign s_o = !(!(!b_i | d_i) & !((!a_i&b_i) | (c_i | !d_i)));

endmodule