/*
Esse modulo calcula 4 saídas, a,b,c,d;

Autor: Santiboy
14 April 2026
*/
module top_secret (
  input       p1_i, 
  input       clk_sys_i,
  input       a_rst, 
  output wire out_a, 
  output reg  out_b,
  output wire out_c,
  output wire out_d 
);

  wire w_temp_s1;
  reg  r_state;

  // Lógica 1: out_a = p1_i AND (!a_rst)
  assign out_a = p1_i & !a_rst;

  // Lógica 2: Processo sequencial para out_b e r_state
  always @(posedge clk_sys or posedge a_rst) begin
    if(a_rst == 1'b1) begin
      out_b <= 1'b0;
      r_state <= 1'b0;
    end else if(p1_i == 1'b1) begin
      out_b <= ~out_b;
      r_state <= 1'b0;
    end
  end

  // Lógica 3: w_temp_s1 = p1_i XOR a_rst
  assign w_temp_s1 = p1_i ^ a_rst;

  // Lógica 4: Lógica combinacional para out_c
  always @* begin
    if (p1_i && r_state)
      out_c = 1'b1; 
    else 
      out_c = !w_temp_s1;
  end

  // Lógica 5: out_d = out_b NOR temp_s1
  assign out_d = ~(out_b | w_temp_s1);

endmodule
