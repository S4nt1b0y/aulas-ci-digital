`ifndef UART_MONITOR_SVH
`define UART_MONITOR_SVH

class uart_monitor extends uvm_monitor;
  `uvm_component_utils(uart_monitor)

  // Clock de 10 MHz e baud rate de 100 kbaud.
  localparam int CLKS_PER_BIT = 100;
  localparam int FRAME_CLKS = 10 * CLKS_PER_BIT;

  longint unsigned cycle = 0;
  longint unsigned prev_end_cycle = 0;

  virtual uart_if vif;

  uvm_analysis_port #(uart_item)  cmd_ap;
  uvm_analysis_port #(uart_frame) tx_ap;

  function new(
    string name = "uart_monitor",
    uvm_component parent = null
  );
    super.new(name, parent);

    cmd_ap = new("cmd_ap", this);
    tx_ap  = new("tx_ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    vif = uart_vif_bridge::vif;

    if (vif == null)
      `uvm_fatal("NOVIF", "uart_if nao foi atribuida ao monitor")
  endfunction

  task run_phase(uvm_phase phase);
    vif.wait_reset_release();
    cycle = 0;
    prev_end_cycle = 0;

    fork
      monitor_commands();
      monitor_serial();
    join
  endtask

  // Observa os comandos aceitos na entrada do DUT.
  task monitor_commands();
    uart_item cmd;

    forever begin
      @(posedge vif.clk);
      cycle++;

      if ((vif.rst_n    === 1'b1) &&
          (vif.tx_start === 1'b1) &&
          (vif.tx_busy  === 1'b0)) begin

        cmd = uart_item::type_id::create("cmd");
        cmd.data = vif.tx_data;

        `uvm_info(
          "MON",
          $sformatf("Command accepted: 0x%02h", cmd.data),
          UVM_MEDIUM
        )

        cmd_ap.write(cmd);
      end
    end
  endtask

  // Reconstrói o frame a partir da saída serial.
  task monitor_serial();
    uart_frame tr;

    forever begin
      // Candidata a início de um frame.
      @(negedge vif.tx_serial);

      if (vif.rst_n !== 1'b1)
        continue;

      tr = uart_frame::type_id::create("tr");

      // Primeiro gap: ciclos contados desde a liberacao do reset.
      // Demais gaps: inicio atual menos o fim nominal do frame anterior.
      tr.gap_clks = cycle - prev_end_cycle;
      prev_end_cycle = cycle + FRAME_CLKS;

      // Amostra no centro do start bit.
      repeat (CLKS_PER_BIT / 2)
        @(posedge vif.clk);

      tr.start_ok = (vif.tx_serial === 1'b0);

      // Amostra D0 até D7: UART transmite LSB primeiro.
      for (int i = 0; i < 8; i++) begin
        repeat (CLKS_PER_BIT)
          @(posedge vif.clk);

        tr.data[i] = vif.tx_serial;
      end

      // Amostra no centro do stop bit.
      repeat (CLKS_PER_BIT)
        @(posedge vif.clk);

      tr.stop_ok = (vif.tx_serial === 1'b1);

      `uvm_info(
        "MON",
        $sformatf(
          "Observed UART frame: data=0x%02h start_ok=%0b stop_ok=%0b gap_clks=%0d",
          tr.data, tr.start_ok, tr.stop_ok, tr.gap_clks
        ),
        UVM_MEDIUM
      )

      tx_ap.write(tr);
    end
  endtask

  endclass

`endif
