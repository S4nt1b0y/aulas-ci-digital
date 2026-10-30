class uart_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(uart_scoreboard)

  uvm_tlm_analysis_fifo #(uart_frame) expected_fifo;
  uvm_tlm_analysis_fifo #(uart_frame) actual_fifo;

  int unsigned num_matches;
  int unsigned num_mismatches;

  // Construtor (Slide 47)
  function new(string name = "uart_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Fase de Construção (Slide 47)
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    expected_fifo = new("expected_fifo", this);
    actual_fifo   = new("actual_fifo",   this);
  endfunction
  
  // (Opcional) Aqui entraria o run_phase para ler as FIFOs e comparar
  // task run_phase(uvm_phase phase);
  //   ...
  // endtask
endclass