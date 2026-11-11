`ifndef UART_SCOREBOARD_SVH
`define UART_SCOREBOARD_SVH

class uart_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(uart_scoreboard)

  uvm_tlm_analysis_fifo #(uart_frame) expected_fifo;
  uvm_tlm_analysis_fifo #(uart_frame) actual_fifo;
  uvm_analysis_imp #(uart_frame, uart_scoreboard) act_imp;
  uart_frame cov_tr;
  int unsigned num_cov_samples = 0;

  covergroup cg_frame;
    option.per_instance = 1;

    cp_data: coverpoint cov_tr.data {
      bins zero        = {8'h00};
      bins all_ones    = {8'hFF};
      bins alternating = {8'h55, 8'hAA};
      bins low[4]      = {[8'h01:8'h7F]};
      bins high[4]     = {[8'h80:8'hFE]};
    }

    // Paridade do byte, nao um bit de paridade no protocolo 8N1.
    cp_parity: coverpoint (^cov_tr.data) {
      bins even = {1'b0};
      bins odd  = {1'b1};
    }

    cp_gap: coverpoint cov_tr.gap_clks {
      bins back_to_back = {[0:10]};
      bins short_gap    = {[11:200]};
      bins long_gap     = {[201:$]};
    }

    cx_data_gap: cross cp_data, cp_gap;
  endgroup

  int unsigned expected_count = 13;
  int unsigned num_matches = 0;
  int unsigned num_mismatches = 0;
  bit waiting_for_actual = 0;

  function new(string name = "uart_scoreboard",
               uvm_component parent = null);
    super.new(name, parent);
    cg_frame = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    void'(uvm_config_db#(int unsigned)::get(
      this, "", "expected_count", expected_count));
    expected_fifo = new("expected_fifo", this);
    actual_fifo = new("actual_fifo", this);
    act_imp = new("act_imp", this);
  endfunction

  function void write(uart_frame t);
    cov_tr = t;
    cg_frame.sample();
    num_cov_samples++;
    actual_fifo.write(t);
  endfunction

  task run_phase(uvm_phase phase);
    uart_frame exp;
    uart_frame act;
    forever begin
      expected_fifo.get(exp);
      waiting_for_actual = 1;
      actual_fifo.get(act);
      waiting_for_actual = 0;

      if ((exp.data !== act.data) ||
          (exp.start_ok !== act.start_ok) ||
          (exp.stop_ok !== act.stop_ok)) begin
        num_mismatches++;
        `uvm_error("SCB", $sformatf(
          {"Mismatch: expected data=0x%02h start_ok=%0b stop_ok=%0b; ",
           "actual data=0x%02h start_ok=%0b stop_ok=%0b"},
          exp.data, exp.start_ok, exp.stop_ok,
          act.data, act.start_ok, act.stop_ok))
      end
      else begin
        num_matches++;
        `uvm_info("SCB", $sformatf(
          "MATCH: UART transmitted 0x%02h", act.data), UVM_LOW)
      end
    end
  endtask

  function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    if (waiting_for_actual)
      `uvm_error("SCB", "Um frame esperado ficou sem resposta")
    if (expected_fifo.used() != 0)
      `uvm_error("SCB", "Frames esperados permaneceram na FIFO")
    if (actual_fifo.used() != 0)
      `uvm_error("SCB", "Frames observados ficaram sem correspondencia")
    if ((num_matches + num_mismatches) != expected_count)
      `uvm_error("SCB", $sformatf(
        "Esperadas %0d comparacoes, realizadas %0d",
        expected_count, num_matches + num_mismatches))
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SCB_SUMMARY", $sformatf(
      "matches=%0d mismatches=%0d pending_expected=%0d pending_actual=%0d",
      num_matches, num_mismatches,
      expected_fifo.used() + int'(waiting_for_actual),
      actual_fifo.used()), UVM_NONE)

    `uvm_info("SCB_COV", $sformatf(
      {"samples=%0d frame coverage=%0.2f%% ",
       "(data=%0.2f%% parity=%0.2f%% gap=%0.2f%% data_x_gap=%0.2f%%)"},
      num_cov_samples,
      cg_frame.get_coverage(),
      cg_frame.cp_data.get_coverage(),
      cg_frame.cp_parity.get_coverage(),
      cg_frame.cp_gap.get_coverage(),
      cg_frame.cx_data_gap.get_coverage()), UVM_NONE)
  endfunction
endclass

`endif
