`ifndef UART_FRAME_SVH
`define UART_FRAME_SVH

class uart_frame extends uvm_sequence_item;
  logic [7:0] data;
  bit start_ok;
  bit stop_ok;
  int unsigned gap_clks;

  `uvm_object_utils_begin(uart_frame)
    `uvm_field_int(data,     UVM_ALL_ON)
    `uvm_field_int(start_ok, UVM_ALL_ON)
    `uvm_field_int(stop_ok,  UVM_ALL_ON)
    `uvm_field_int(gap_clks, UVM_ALL_ON | UVM_DEC | UVM_NOCOMPARE)
  `uvm_object_utils_end

  function new(string name = "uart_frame");
    super.new(name);
  endfunction
endclass

`endif
