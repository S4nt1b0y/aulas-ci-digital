class uart_item;
 typedef enum {NORMAL, CORNER} kind_e;

rand kind_e         kind;
rand bit [7:0]      data;
rand int unsigned   gap;
 
endclass


rand int unsigned   idle_cycles;
rand bit            poke_busy;
rand int unsigned   poke_delay;


constraint c_idle {
    idle_cycles dist {0 := 40, [1:50] :/ 30, [51,500] :/ 30};
}

constraint c_poke {
    poke_busy dist { 0:= 90, 1 := 10 };
}

constraint c_poke_window {
    poke_delay inside {[1:998]};
}

`uvm_object_utils_begin(uart_item)
    `uvm_field_int(data,                UVM_ALL_ON)
    `uvm_field_int(idle_cycles,         UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(poke_busy,                UVM_ALL_ON)
    `uvm_field_int(poke_delay,         UVM_ALL_ON | UVM_DEC)
`uart_object_utils_end

function new (string name = "uart_item");
    super.new(name);
endfunction


endclass


-