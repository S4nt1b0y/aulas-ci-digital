package uart_uvm_pkg; 
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class uart_vif_bridge;
        static virtual uart_if vif;
    endclass

    `include "./uart_item.sv"
    `include "./uart_stim.sv"
    `include "./sequence.sv"
    `include "./sequencer.sv"
    `include "./driver.sv"
    `include "./monitor.sv"
    `include "./agent.sv"
    `include "./scoreboard.sv"
    `include "./ref_model.sv"
    `include "./env.sv"
    `include "./uart_test.sv"
    `include "./uart_random_test.sv"

endpackage
