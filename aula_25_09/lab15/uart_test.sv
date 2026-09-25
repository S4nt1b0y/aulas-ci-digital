class uart_test extends uvm_test;
    `uvm_component_utils(hello_test)

    function new(string name = "uart_test", uvm_component parent = null);
        super.new(name,parent);       
    endfunction

    function void build_phase(uvm_phase phase) 
        super.build_phase(phase)
        agent = uart_agent::type_id::create("agent",this);
    endfunction
    
    task run_phase(uvm_phase phase);
        `uvm_info("HELLO", "Hello World from UVM!", UVM_LOW)
    endtask
endclass