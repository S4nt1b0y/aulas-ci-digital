class uart_driver extends uvm_driver #(uart_item);
    `uvm_component_utils(uart_driver)

    virtual uart_if vif;

    function new(string name = "uart_driver",
                 uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      vif = uart_vif_bridge::vif;
      if (vif == null)
        `uvm_fatal("NOVIF", "uart_if was not assigned")
    endfunction

    task run_phase(uvm_phase phase);
      uart_item req;
      vif.wait_reset_release();
      forever begin
        seq_item_port.get_next_item(req);
        `uvm_info("DRV", $sformatf("Received item: data=0x%02h", req.data), UVM_MEDIUM)
        drive_item(req);
        seq_item_port.item_done();
      end
    endtask

    task automatic drive_byte(input logic [7: 0] data);
      while (vif.tx_busy !== 1'b0) @(posedge vif.clk);

      @(posedge vif.clk);
      vif.tx_data <= data;
      vif.tx_start <= 1'b1;

      @(posedge vif.clk);
      vif.tx_start <= 1'b0;

      do @(posedge vif.clk);
      while (vif.tx_done !== 1'b1);
    endtask

    task drive_item(uart_item req);
        while (vif.tx_busy !== 1'b0) @(posedge vif.clk);

        @(posedge vif.clk);
        vif.tx_data  <= req.data;
        vif.tx_start <= 1'b1;
        @(posedge vif.clk);
        vif.tx_start <= 1'b0;

        if (req.poke_busy) begin
            repeat (req.poke_delay) @(posedge vif.clk);
            vif.tx_data  <= ~req.data;  // valor "intruso"
            vif.tx_start <= 1'b1;
            @(posedge vif.clk);
            vif.tx_start <= 1'b0;
        end

        do @(posedge vif.clk);
        while (vif.tx_done !== 1'b1);
    endtask
  endclass