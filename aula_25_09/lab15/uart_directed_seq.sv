class uart_directed_seq extends uvm_sequence #(uart_item);
    `uvm_object_utils(uart_directed_seq)

    int unsigned num_items = 5;

    bit [7:0] pattern[4] = '{8'h55, 8'hA3, 8'h00, 8'hFF};
    
    function new(string name= "uart_directed_seq");
        super.new(name);   
    endfunction

    task body();
        uart_item req;
        foreach(pattern[i]) begin
            req = uart_item::type_id::create("req");
            start_item(req);
            req.data = pattern[i];
            finish_item(req);
        end
    endtask
endclass 