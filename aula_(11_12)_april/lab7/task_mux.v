module task_mux (
    output [2:0] mux_indice
);

    reg [2:0] mux_indice_reg = 3'b0;

    task get_index (input [2:0] mux_indice);
        begin
            mux_indice_reg <= mux_indice  + 1'b1;
            #5; 
        end
    endtask

    always begin
        get_index(mux_indice_reg);
    end

    assign mux_indice = mux_indice_reg;

endmodule