class uart_basic_seq extends uvm_sequence #(uart_item);
    `uvm_object_util(uart_basic_seq)

    int unsigned num_items = 5;

    function new(string name= "uart_basiq_seq");
        super.new(name);   
    endfunction

    task body();
        uart_item req;
        repeat (num_items) begin
            req = uart_item::type_id::create("req");
            start_item(req);
            if (!req.randomize())
                `uvm_fatal("RAND", "uart_item randomization failed")
            finish_item(req);
        end
    endtask
endclass 