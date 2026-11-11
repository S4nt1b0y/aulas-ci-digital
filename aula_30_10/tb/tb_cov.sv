 `include "uart_stim.sv"

 class frame_cov;
     bit [7:0] data;
     int unsigned gap;

     covergroup cg_frame;
         cp_data: coverpoint data {
             bins zero = {8'h00};
             bins all_ones = {8'hFF};
             bins alternating = {8'h55, 8'hAA};
             bins low[4] = {[8'h01:8'h7F]};
             bins high[4] = {[8'h80:8'hFE]};
         }

         cp_parity: coverpoint ^data {
             bins even = {1'b0};
             bins odd = {1'b1};
         }

         cp_gap: coverpoint gap {
             bins back_to_back = {[0:10]};
             bins short_gap = {[11:200]};
             bins long_gap = {[201:$]};
         }

         cx_data_gap: cross cp_data, cp_gap;
     endgroup

     function new();
         cg_frame = new(); // obrigatório no construtor
     endfunction

     function void sample(bit [7:0] d, int unsigned g);
         data = d;
         gap = g;
         cg_frame.sample();
     endfunction
 endclass

 module tb_cov;
     initial begin
         uart_stim s = new();
         frame_cov cov = new();
         int unsigned n = 50;

         void'($value$plusargs("N=%d", n));

         repeat (n) begin
             if (!s.randomize())
                 $fatal(1, "randomize() falhou");
             cov.sample(s.data, s.gap);
         end

         $display("amostras=%0d", n);
         $display("cg_frame = %0.2f%%", cov.cg_frame.get_coverage());
         $display("cp_data = %0.2f%%", cov.cg_frame.cp_data.get_coverage());
         $display("cp_parity = %0.2f%%", cov.cg_frame.cp_parity.get_coverage());
         $display("cp_gap = %0.2f%%", cov.cg_frame.cp_gap.get_coverage());
         $display("cx_data_gap = %0.2f%%", cov.cg_frame.cx_data_gap.get_coverage());
     end
 endmodule