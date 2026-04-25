module task_mux_tb;

    wire [2:0] mux_indice;

    task_mux dut (
        .mux_indice(mux_indice)
    );

    initial begin
        $display("Tempo\tmux_indice");
        $monitor("%0t\t%b", $time, mux_indice);

        #50;

        $display("Finalizando teste.");
        $finish;
    end

endmodule