package uart_uvm_pkg; 
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class uart_vif_bridge;
        static virtual uart_if vif;
    endclass

    `include "./uart_item.sv"
    `include "./uart_basic_seq.sv"
    `include "./uart_directed_seq.sv"
    `include "./uart_sequencer.sv"
    `include "./uart_driver.sv"
    `include "./uart_agent.sv"
    `include "./uart_test.sv"

endpackage
