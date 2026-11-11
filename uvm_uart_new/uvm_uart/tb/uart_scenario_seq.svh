`ifndef UART_SCENARIO_SEQ_SVH
`define UART_SCENARIO_SEQ_SVH

class uart_scenario_seq extends uvm_sequence #(uart_item);
  `uvm_object_utils(uart_scenario_seq)

  function new(string name = "uart_scenario_seq");
    super.new(name);
  endfunction

  task body();
    uart_send_byte_seq send;
    uart_random_burst_seq burst;
    bit [7:0] pattern[5] = '{8'h00, 8'hFF, 8'h55, 8'hAA, 8'hA3};

    foreach (pattern[i]) begin
      send = uart_send_byte_seq::type_id::create(
        $sformatf("send_%0d", i));
      send.value = pattern[i];
      send.start(m_sequencer, this);
    end

    burst = uart_random_burst_seq::type_id::create("burst");
    burst.count = 8;
    burst.start(m_sequencer, this);
  endtask
endclass

`endif
