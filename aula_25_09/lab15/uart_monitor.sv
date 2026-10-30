class uart_monitor extends uvm_monitor;
  `uvm_component_utils(uart_monitor)

  localparam int CLKS_PER_BIT = 100;

  virtual uart_if vif;

  uvm_analysis_port #(uart_item)   cmd_ap;
  uvm_analysis_port #(uart_frame)  tx_ap;

  // Construtor (Slide 23)
  function new(string name = "uart_monitor", uvm_component parent = null);
    super.new(name, parent);

    cmd_ap = new("cmd_ap", this);
    tx_ap  = new("tx_ap", this);
  endfunction

  // Fase de Construção (Slide 24)
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    vif = uart_vif_bridge::vif;

    if (vif == null)
      `uvm_fatal("NOVIF", "uart_if was not assigned")
  endfunction

  // Fase de Execução (Slide 25)
  task run_phase(uvm_phase phase);
    vif.wait_reset_release();

    fork
      monitor_commands();
      monitor_serial();
    join
  endtask

  // Tarefa 1: Monitorando Comandos (Slide 26)
  task monitor_commands();
    uart_item cmd;

    forever begin
      @(posedge vif.clk);

      if (vif.rst_n &&
          vif.tx_start === 1'b1 &&
          vif.tx_busy  === 1'b0) begin

        cmd = uart_item::type_id::create("cmd");
        cmd.data = vif.tx_data;

        cmd_ap.write(cmd);
      end
    end
  endtask

  // Tarefa 2: Monitorando o Frame Serial (Slides 28, 29 e 30)
  task monitor_serial();
    uart_frame tr;

    forever begin
      // Aguarda a borda de descida na linha serial (Slide 28)
      @(negedge vif.tx_serial);

      if (!vif.rst_n)
        continue;

      tr = uart_frame::type_id::create("tr");

      // Confirmação do Start Bit no centro (Slide 28)
      repeat (CLKS_PER_BIT/2)
        @(posedge vif.clk);

      tr.start_ok = (vif.tx_serial === 1'b0);

      // Coleta dos 8 bits de dados - LSB first (Slide 29)
      for (int i = 0; i < 8; i++) begin
        repeat (CLKS_PER_BIT)
          @(posedge vif.clk);

        tr.data[i] = vif.tx_serial;
      end

      // Verificação do Stop Bit (Slide 30)
      repeat (CLKS_PER_BIT)
        @(posedge vif.clk);

      tr.stop_ok = (vif.tx_serial === 1'b1);

      // Publicação do frame observado (Slide 30)
      `uvm_info("MON",
        $sformatf(
          "Observed UART frame: data=0x%02h start_ok=%0b stop_ok=%0b",
          tr.data, tr.start_ok, tr.stop_ok),
        UVM_MEDIUM)

      tx_ap.write(tr);
    end
  endtask
endclass