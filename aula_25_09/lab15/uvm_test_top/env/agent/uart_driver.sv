class uart_driver extends uvm_driver #(uart_item);
    `uvm_component_utils(uart_driver)

    virtual uart_if vif;

    function new(string name = "uart_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        vif = uart_vif_bridge::vif;
        if(vif == null)
            `uvm_fatal("NOIF","uart_if was not assigned")
    endfunction

    task run_phase(uvm_phase phase);
        uart_item req;
        vif.wait_reset_release();
        forever begin
            seq_item_port.get_next_item(req);
            `uvm_info("DRV", $sformatf("Received item: data=0x%02h", req.data), UVM_MEDIUM)
            vif.drive_byte(req.data);
            seq_item_port.item_done();
        end
    endtask 
endclass 