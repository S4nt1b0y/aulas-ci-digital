class uart_ref_model extends uvm_component;

    `uvm_component_utils(uart_ref_model)

    uvm_analysis_imp #(uart_item, uart_ref_model) cmd_imp;
    uvm_analysis_port #(uart_item) exp_ap;

    function new(string name = "uart_ref_model",
                 uvm_component parent = null);
      super.new(name, parent);
      cmd_imp = new("cmd_imp", this);
      exp_ap = new("exp_ap", this);
    endfunction

    function void write(uart_item cmd);
      uart_item exp;
      exp = uart_item::type_id::create("exp");

      exp.data = cmd.data;
      exp.start_ok = 1'b1;
      exp.stop_ok = 1'b1;

      exp_ap.write(exp);
    endfunction

  endclass