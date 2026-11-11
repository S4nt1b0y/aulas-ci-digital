`ifndef UART_SEND_BYTE_SEQ_SVH
`define UART_SEND_BYTE_SEQ_SVH

class uart_send_byte_seq extends uvm_sequence #(uart_item);
  `uvm_object_utils(uart_send_byte_seq)
  bit [7:0] value;

  function new(string name = "uart_send_byte_seq");
    super.new(name);
  endfunction

  task body();
    uart_item req;
    req = uart_item::type_id::create("req");
    start_item(req);
    req.data = value;
    finish_item(req);
  endtask
endclass

`endif
