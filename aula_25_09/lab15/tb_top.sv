module tb_top;
    import uvm_pkg::*;
    import uart_uvm_pkg::*;

    logic   clk = 1'b0;
    always #50ns clk = ~clk;

    uart_if uart_bus(clk);

    uart_tx_dut #() dut (
        .clk(clk),
        .rst_n(uart_bus.rst_n),
        .tx_start(uart_bus.tx_start),
        .tx_data(uart_bus.tx_data),
        .tx_busy(uart_bus.tx_busy),
        .tx_serial(uart_bus.tx_serial),
        .tx_done(uart_bus.tx_done)
    );

    initial begin 
        uart_bus.rst_n = 1'b0;
        uart_bus.tx_start = 1'b0;
        uart_bus.tx_data = '0;
        repeat (5) @(posedge clk);
        uart_bus.rst_n = 1'b1;
    end

    initial begin 
        uart_vif_bridge::vif = uart_bus;
        run_test();
    end
endmodule