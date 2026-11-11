`ifndef UART_POKE_ITEM_SVH
`define UART_POKE_ITEM_SVH

class uart_poke_item extends uart_item;
  `uvm_object_utils(uart_poke_item)
  constraint c_poke { poke_busy == 1; }
  function new(string name = "uart_poke_item");
    super.new(name);
  endfunction
endclass

`endif
