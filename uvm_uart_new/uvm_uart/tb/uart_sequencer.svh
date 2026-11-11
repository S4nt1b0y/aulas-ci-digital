`ifndef UART_SEQUENCER_SVH
`define UART_SEQUENCER_SVH

class uart_sequencer extends uvm_sequencer #(uart_item);
  `uvm_component_utils(uart_sequencer)

  function new(string name = "uart_sequencer",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction
endclass

`endif
