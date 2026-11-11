package uart_uvm_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class uart_vif_bridge;
    static virtual uart_if vif;
  endclass

  class uart_item extends uvm_sequence_item;
    rand bit [7: 0] data;
    
    `uvm_object_utils_begin(uart_item)
      `uvm_field_int(data, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "uart_item");
      super.new(name);
    endfunction
  endclass

  class uart_frame extends uvm_sequence_item;
    logic [7: 0] data;
    bit start_ok;
    bit stop_ok;

    `uvm_object_utils_begin(uart_frame)
      `uvm_field_int(data, UVM_ALL_ON)
      `uvm_field_int(start_ok, UVM_ALL_ON)
      `uvm_field_int(stop_ok, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "uart_frame");
      super.new(name);
    endfunction
  endclass

  class uart_basic_seq extends uvm_sequence #(uart_item);
    `uvm_object_utils(uart_basic_seq)

    int unsigned num_items = 5;

    function new(string name = "uart_basic_seq");
      super.new(name);
    endfunction

    task body();
      uart_item req;
      repeat (num_items) begin
        req = uart_item::type_id::create("req");
        start_item(req);
        if (!req.randomize())
          `uvm_fatal("RAND", "uart_item randomization failed")
        finish_item(req);
      end
    endtask 
  endclass

  class uart_directed_seq extends uvm_sequence #(uart_item);
    `uvm_object_utils(uart_directed_seq)

    int unsigned pattern [] = '{8'h55, 8'hA3, 8'h00, 8'hFF};

    function new(string name = "uart_directed_seq");
      super.new(name);
    endfunction

    task body();
      uart_item req;
      foreach (pattern[i]) begin
        req = uart_item::type_id::create("req");
        start_item(req);
        req.data = pattern[i];
        finish_item(req);
      end
    endtask
  endclass

  class uart_sequencer extends uvm_sequencer #(uart_item);
    `uvm_component_utils(uart_sequencer)

    function new(string name = "uart_sequencer",
                 uvm_component parent = null);
      super.new(name, parent);
    endfunction
  endclass

  class uart_driver extends uvm_driver #(uart_item);
    `uvm_component_utils(uart_driver)

    virtual uart_if vif;

    function new(string name = "uart_driver",
                 uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      vif = uart_vif_bridge::vif;
      if (vif == null)
        `uvm_fatal("NOVIF", "uart_if was not assigned")
    endfunction

    task run_phase(uvm_phase phase);
      uart_item req;
      vif.wait_reset_release();
      forever begin
        seq_item_port.get_next_item(req);
        `uvm_info("DRV", $sformatf("Received item: data=0x%02h", req.data), UVM_MEDIUM)
        drive_byte(req.data);
        seq_item_port.item_done();
      end
    endtask

    task automatic drive_byte(input logic [7: 0] data);
      while (vif.tx_busy !== 1'b0) @(posedge vif.clk);

      @(posedge vif.clk);
      vif.tx_data <= data;
      vif.tx_start <= 1'b1;

      @(posedge vif.clk);
      vif.tx_start <= 1'b0;

      do @(posedge vif.clk);
      while (vif.tx_done !== 1'b1);
    endtask
  endclass

  class uart_monitor extends uvm_monitor;
    `uvm_component_utils(uart_monitor)

    localparam int CLKS_PER_BIT = 100;

    virtual uart_if vif;

    uvm_analysis_port #(uart_item) cmd_ap;
    uvm_analysis_port #(uart_frame) tx_ap;

    function new(string name = "uart_monitor", uvm_component parent = null);
      super.new(name, parent);
      cmd_ap = new("cmd_ap", this);
      tx_ap = new("tx_ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      vif = uart_vif_bridge::vif;

      if (vif == null)
        `uvm_fatal("NOVIF", "uart_if was not assigned")
    endfunction

    task monitor_commands();
      uart_item cmd;

      forever begin
        @(posedge vif.clk);

        if (vif.rst_n &&
            vif.tx_start === 1'b1 &&
            vif.tx_busy === 1'b0) begin
          cmd = uart_item::type_id::create("cmd");
          cmd.data = vif.tx_data;
          cmd_ap.write(cmd);
        end
      end
    endtask 

    task monitor_serial();
      uart_frame tr;

      forever begin
        @(negedge vif.tx_serial);

        if (!vif.rst_n) begin
          @(posedge vif.clk);
          continue;
        end

        tr = uart_frame::type_id::create("tr");

        repeat(CLKS_PER_BIT/2)
          @(posedge vif.clk);
        
        tr.start_ok = (vif.tx_serial === 1'b0);

        for (int i = 0; i < 8; i++) begin
          repeat(CLKS_PER_BIT)
            @(posedge vif.clk);

          tr.data[i] = vif.tx_serial;
        end

        repeat(CLKS_PER_BIT)
          @(posedge vif.clk);

        tr.stop_ok = (vif.tx_serial === 1'b1);

        `uvm_info("MON",
                  $sformatf(
                    "Observed UART frame: data=0x%02h start_ok=%0b stop_ok=%0b",
                    tr.data, tr.start_ok, tr.stop_ok
                  ), UVM_MEDIUM)

        tx_ap.write(tr);
      end
    endtask

    task run_phase(uvm_phase phase);
      vif.wait_reset_release();

      fork
        monitor_commands();
        monitor_serial();
      join_none
    endtask
  endclass

  class uart_agent extends uvm_agent;
    `uvm_component_utils(uart_agent)

    uart_sequencer sequencer;
    uart_driver driver;
    uart_monitor monitor;

    function new(string name = "uart_agent",
                 uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = uart_sequencer::type_id::create("sequencer", this);
      driver = uart_driver::type_id::create("driver", this);
      monitor = uart_monitor::type_id::create("monitor", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
  endclass

  class uart_ref_model extends uvm_component;

    `uvm_component_utils(uart_ref_model)

    uvm_analysis_imp #(uart_item, uart_ref_model) cmd_imp;
    uvm_analysis_port #(uart_frame) exp_ap;

    function new(string name = "uart_ref_model",
                 uvm_component parent = null);
      super.new(name, parent);
      cmd_imp = new("cmd_imp", this);
      exp_ap = new("exp_ap", this);
    endfunction

    function void write(uart_item cmd);
      uart_frame exp;
      exp = uart_frame::type_id::create("exp");

      exp.data = cmd.data;
      exp.start_ok = 1'b1;
      exp.stop_ok = 1'b1;

      exp_ap.write(exp);
    endfunction

  endclass

  class uart_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(uart_scoreboard)

    uvm_tlm_analysis_fifo #(uart_frame) expected_fifo;
    uvm_tlm_analysis_fifo #(uart_frame) actual_fifo;

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
      uart_frame exp;
      uart_frame act;

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

  class uart_env extends uvm_env;
  
    `uvm_component_utils(uart_env)

    uart_agent agent;
    uart_ref_model ref_model;
    uart_scoreboard scoreboard;

    function new(string name = "uart_env",
                 uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      
      agent = uart_agent::type_id::create("agent", this);
      ref_model = uart_ref_model::type_id::create("ref_model", this);
      scoreboard = uart_scoreboard::type_id::create("scoreboard", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);

      agent.monitor.cmd_ap.connect(ref_model.cmd_imp);
      ref_model.exp_ap.connect(scoreboard.expected_fifo.analysis_export);
      agent.monitor.tx_ap.connect(scoreboard.actual_fifo.analysis_export);

    endfunction

  endclass

  class uart_test extends uvm_test;
    `uvm_component_utils(uart_test)

    uart_env env;

    function new(string name = "uart_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = uart_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
      uart_basic_seq seq;

      phase.raise_objection(this);
      seq = uart_basic_seq::type_id::create("seq");
      seq.start(env.agent.sequencer);
      phase.drop_objection(this);
    endtask

  endclass

endpackage