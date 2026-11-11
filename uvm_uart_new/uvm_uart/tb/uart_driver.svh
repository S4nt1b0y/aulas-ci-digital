`ifndef UART_DRIVER_SVH
`define UART_DRIVER_SVH

class uart_driver extends uvm_driver #(uart_item);
  `uvm_component_utils(uart_driver)
  virtual uart_if vif;
  int unsigned num_items_driven = 0;
  int unsigned num_pokes = 0;

  function new(string name = "uart_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    vif = uart_vif_bridge::vif;
    if (vif == null)
      `uvm_fatal("NOVIF", "uart_if was not assigned")
  endfunction

  task drive_item(uart_item req);
    while (vif.tx_busy !== 1'b0) @(posedge vif.clk);

    // NBA: entradas estaveis antes da proxima amostragem do DUT.
    @(posedge vif.clk);
    vif.tx_data  <= req.data;
    vif.tx_start <= 1'b1;
    @(posedge vif.clk);
    vif.tx_start <= 1'b0;

    if (req.poke_busy) begin
      repeat (req.poke_delay) @(posedge vif.clk);
      if (vif.tx_busy !== 1'b1)
        `uvm_fatal("POKE_WINDOW",
          "O poke saiu da janela busy; confira clock, baud e poke_delay")

      // O DUT deve ignorar este novo pedido durante busy.
      vif.tx_data  <= ~req.data;
      vif.tx_start <= 1'b1;
      num_pokes++;
      `uvm_info("POKE", $sformatf(
        "item=%0d time=%0t original=0x%02h intruso=0x%02h delay=%0d busy=%0b",
        num_items_driven, $time, req.data, ~req.data,
        req.poke_delay, vif.tx_busy), UVM_LOW)
      @(posedge vif.clk);
      vif.tx_start <= 1'b0;
    end

    // wait tambem reconhece tx_done se ele ja estiver alto.
    wait (vif.tx_done === 1'b1);
  endtask

  task run_phase(uvm_phase phase);
    uart_item req;
    vif.wait_reset_release();
    forever begin
      seq_item_port.get_next_item(req);
      num_items_driven++;
      `uvm_info("DRV", $sformatf(
        "item=%0d data=0x%02h idle_cycles=%0d poke_busy=%0b poke_delay=%0d",
        num_items_driven, req.data, req.idle_cycles,
        req.poke_busy, req.poke_delay), UVM_MEDIUM)
      repeat (req.idle_cycles) @(posedge vif.clk);
      drive_item(req);
      seq_item_port.item_done();
    end
  endtask

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("DRV_SUMMARY", $sformatf(
      "items=%0d pokes=%0d", num_items_driven, num_pokes), UVM_NONE)
  endfunction
endclass

`endif
