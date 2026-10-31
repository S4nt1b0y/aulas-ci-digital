class uart_random_test extends uart_test;
    `uvm_component_utils(uart_random_test)

    task run_phase(uvm_phase phase);
        uart_poke_seq seq;
        int unsigned n = 50;

        void'($value$plusargs("NUM_ITEMS=%d", n));

        phase.raise_objection(this);
        seq = uart_poke_seq::type_id::create("seq");
        seq.count = n;
        seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask

endclass