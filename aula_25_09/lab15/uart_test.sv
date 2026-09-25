class uart_test extends uvm_test;
    `uvm_component_utils(uart_test)

    uart_agent agent;

    function new(string name = "uart_test",
                uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
       super.build_phase(phase);
       agent = uart_agent::type_id::create("agent",this);
    endfunction  
    
     task run_phase(uvm_phase phase);
            uart_directed_seq seq;

            phase.raise_objection(this);
            seq = uart_directed_seq::type_id::create("seq");
            seq.start(agent.sequencer);
            phase.drop_objection(this);
        endtask    



    endclass