class uart_agent extens uvm_agent;
    `uvm_component_utils(uart_agent)

    uart_sequencer sequencer;
    uart_driver driver;

    function new(string name = "uart_agent", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sequencer = uart_sequencer::type_id::create("sequencer", this); 
        driver = uart_driver::type_id::create("driver", this);       
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);        
    endfunction
endclass