`ifndef UART_TEST_SVH
`define UART_TEST_SVH

class uart_test extends uvm_test;
  `uvm_component_utils(uart_test)

  uart_env env;

  function new(string name = "uart_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = uart_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    uart_scenario_seq seq;
    phase.raise_objection(this);
    seq = uart_scenario_seq::type_id::create("seq");

    // Mantem a objection ate o cenario e as comparacoes terminarem.
    // Limite dimensionado para 13 frames a 100 kbaud (~1,3 ms).
    fork
      begin
        seq.start(env.agent.sequencer);
        wait ((env.scoreboard.num_matches +
               env.scoreboard.num_mismatches) >= 13);
      end
      begin
        #2ms;
        `uvm_fatal("TIMEOUT",
          "Cenario ou checking nao terminou dentro de 2 ms")
      end
    join_any
    disable fork;

    phase.drop_objection(this);
  endtask
endclass

`endif
