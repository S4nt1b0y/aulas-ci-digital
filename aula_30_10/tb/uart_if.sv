interface uart_if(input logic clk);
  logic rst_n;
  logic tx_start;
  logic [7: 0] tx_data;
  logic tx_busy;
  logic tx_serial;
  logic tx_done;

  task automatic wait_reset_release();
    if (!rst_n) @(posedge rst_n);
  endtask

endinterface