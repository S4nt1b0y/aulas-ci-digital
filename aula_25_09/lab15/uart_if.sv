interface uart_if(
    input logic clk); 

    logic rst_n;
    logic tx_start;
    logic[7:0] tx_data;
    logic   tx_busy;
    logic tx_serial;
    logic tx_done;

    task automatic wait_reset_release();
        if(!rst_n) @(posedge rst_n);
    endtask

    task automatic drive_byte(input logic[7:0] data);
        while (tx_busy !== 1'b0) @(posedge clk);

        @(posedge clk)
        tx_data <= data;
        tx_start <= 1'b1;

        @(posedge clk)
        tx_start <= 1'b0;

        do @(posedge clk)
        while (tx_done !== 1'b1);
    endtask
endinterface