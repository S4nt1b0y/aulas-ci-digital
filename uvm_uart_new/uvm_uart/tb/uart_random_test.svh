`ifndef UART_RANDOM_TEST_SVH
`define UART_RANDOM_TEST_SVH

class uart_random_test extends uart_test;
  `uvm_component_utils(uart_random_test)
  int unsigned num_items = 50;
  bit force_pokes;

  function new(string name = "uart_random_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    int n;
    n = 50;
    void'($value$plusargs("NUM_ITEMS=%d", n));
    if (n <= 0)
      `uvm_fatal("NUM_ITEMS", "NUM_ITEMS deve ser maior que zero")
    num_items = n;
    force_pokes = $test$plusargs("FORCE_POKES");

    // Configurar antes da criacao do ambiente pelo teste pai.
    uvm_config_db#(int unsigned)::set(
      this, "env", "expected_count", num_items);
    uvm_config_db#(int unsigned)::set(
      this, "env.scoreboard", "expected_count", num_items);
    super.build_phase(phase);
  endfunction

  task run_phase(uvm_phase phase);
    uart_random_burst_seq seq;
    uart_poke_seq poke_seq;
    time timeout_budget;

    // Cada item: ~100 us de frame + ate 50 us de idle.
    timeout_budget = (time'(num_items) + 1) * 200us;
    phase.raise_objection(this);
    `uvm_info("RANDOM_TEST", $sformatf(
      "NUM_ITEMS=%0d FORCE_POKES=%0b timeout=%0t",
      num_items, force_pokes, timeout_budget), UVM_LOW)

    fork
      begin
        if (force_pokes) begin
          poke_seq = uart_poke_seq::type_id::create("poke_seq");
          poke_seq.count = num_items;
          poke_seq.start(env.agent.sequencer);
        end
        else begin
          seq = uart_random_burst_seq::type_id::create("seq");
          seq.count = num_items;
          seq.start(env.agent.sequencer);
        end
        wait ((env.scoreboard.num_matches +
               env.scoreboard.num_mismatches) >= num_items);
        repeat (2) @(posedge uart_vif_bridge::vif.clk);
      end
      begin
        #(timeout_budget);
        `uvm_fatal("TIMEOUT",
          "Cenario ou checking nao terminou no prazo")
      end
    join_any
    disable fork;
    `uvm_info("TEST_DONE", "Cenario aleatorio concluido", UVM_LOW)
    phase.drop_objection(this);
  endtask
endclass

`endif
