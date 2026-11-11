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