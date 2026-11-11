class uart_poke_seq extends uvm_sequence #(uart_item);
    `uvm_object_utils(uart_poke_seq)

    int unsigned count = 4;

    task body();
        uart_poke_item req;
        repeat (count) begin
            req = uart_poke_item::type_id::create("req");
            start_item(req);
            if (!req.randomize())
                `uvm_fatal("RAND", "uart_poke_item randomization failed")
            finish_item(req);
        end
    endtask
endclass