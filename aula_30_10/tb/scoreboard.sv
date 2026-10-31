class uart_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(uart_scoreboard)

    uvm_tlm_analysis_fifo #(uart_item) expected_fifo;
    uvm_tlm_analysis_fifo #(uart_item) actual_fifo;

    int unsigned num_matches;
    int unsigned num_mismatches;

    function new(string name = "uart_scoreboard",
                 uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      
      expected_fifo = new("expected_fifo", this);
      actual_fifo = new("actual_fifo", this);
    endfunction

    task run_phase(uvm_phase phase);
      uart_item exp;
      uart_item act;

      forever begin
        expected_fifo.get(exp);
        actual_fifo.get(act);

        if ((exp.data !== act.data) ||
            (exp.start_ok != act.start_ok) ||
            (exp.stop_ok != act.stop_ok)) begin
          num_mismatches++;
          
          `uvm_error("SCB",
            $sformatf(
              "Mismatch: expected data=0x%02h start=%0b stop=%0b; actual data=0x%02h start=%0b stop=%0b",
              exp.data, exp.start_ok, exp.stop_ok,
              act.data, act.start_ok, act.stop_ok
            ));
        end
        else begin
          num_matches++;

          `uvm_info("SCB",
            $sformatf("MATCH: UART transmitted 0x%02h", act.data),
            UVM_LOW)
        end
      end
    endtask
     function void check_phase(uvm_phase phase);
      super.check_phase(phase);

      if (expected_fifo.used() != 0)
        `uvm_error("SCB", "Expected frames remained unmatched")

      if (actual_fifo.used() != 0)
        `uvm_error("SCB", "Unexpected actual frames remained")
    endfunction

    function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      
      `uvm_info("SCB_SUMMARY",
                $sformatf("matches=%0d mismatches=%0d",
                          num_matches, num_mismatches),
                UVM_NONE)

    endfunction

  endclass