`ifndef UART_RANDOM_BURST_SEQ_SVH
`define UART_RANDOM_BURST_SEQ_SVH

class uart_random_burst_seq extends uvm_sequence #(uart_item);
  `uvm_object_utils(uart_random_burst_seq)
  int unsigned count = 8;

  function new(string name = "uart_random_burst_seq");
    super.new(name);
  endfunction

  task body();
    uart_item req;
    repeat (count) begin
      req = uart_item::type_id::create("req");
      start_item(req);
      if (!req.randomize())
        `uvm_fatal("RAND", "uart_item randomization failed")
      finish_item(req);
    end
  endtask
endclass

`endif
