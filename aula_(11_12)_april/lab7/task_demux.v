module task_demux (
    input [2:0] data_in,
    output reg [7:0] data_out
);

    task active_bit;
        input [2:0] data_in;
        begin
            data_out = 8'b0;
            data_out[data_in] = 1'b1;
        end
    endtask

    always @(*) begin
        active_bit(data_in);
    end

endmodule