`ifndef UART_BASIC_SEQ_SVH
`define UART_BASIC_SEQ_SVH

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

`endif
