class uart_item extends uvm_sequence_item;
    rand bit [7:0] data;

    function new(string name = "uart_item");
        super.new(name);
    endfunction
endclass