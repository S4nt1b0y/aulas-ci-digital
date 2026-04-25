`timescale 1ns/1ps

module task_demux_tb;

    reg [2:0] data_in;
    wire [7:0] data_out;

    integer i;
    reg [7:0] expected;

    // Instância do DUT
    task_demux dut (
        .data_in(data_in),
        .data_out(data_out)
    );

    initial begin
        $display("Iniciando testes...");

        for (i = 0; i < 8; i = i + 1) begin
            data_in = i;
            #1;

            expected = 8'b0;
            expected[i] = 1'b1;

            if (data_out !== expected) begin
                $display("ERRO: in=%0d | out=%b | esperado=%b",
                          data_in, data_out, expected);
            end else begin
                $display("OK: in=%0d | out=%b",
                          data_in, data_out);
            end
        end

        $finish;
    end

endmodule