class uart_frame extends uvm_sequence_item;

    logic [7:0] data;
    bit         start_ok;
    bit         stop_ok;

    `uvm_object_utils_begin(uart_frame)
      `uvm_field_int(data,     UVM_ALL_ON)
      `uvm_field_int(start_ok, UVM_ALL_ON)
      `uvm_field_int(stop_ok,  UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "uart_frame");
      super.new(name);
    endfunction
endclass