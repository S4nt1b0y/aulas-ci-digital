`timescale 1ns/1ps

module tb_serdes();

    reg clk = 0;
    reg rst = 1;
    reg load = 0;
    reg enable = 0;

    reg [7:0] data_in;

    wire [7:0] data_out;
    wire done;
    wire error;

    integer i;
    reg erro;

    serdes #(
        .WIDTH(8)
    ) sd (
        .clk(clk),
        .rst(rst),
        .load(load),
        .data_in(data_in),
        .enable(enable),
        .data_out(data_out),
        .done(done),
        .error(error)
    );

    always #5 clk = ~clk;

    initial begin

        erro = 0;

        for (i = 0; i < 10; i = i + 1) begin

            rst    = 1;
            load   = 0;
            enable = 0;

            @(posedge clk);
            @(posedge clk);

            rst = 0;

            //-----------------------------------------
            // Carrega dado
            //-----------------------------------------
            data_in = i[7:0];

            @(posedge clk);
            load = 1;

            @(posedge clk);
            load = 0;

            //-----------------------------------------
            // Inicia recepção
            //-----------------------------------------
            enable = 1;

            wait(done);

            @(posedge clk);

            enable = 0;

            //-----------------------------------------
            // Verificações
            //-----------------------------------------
            if (data_out !== data_in) begin
                erro = 1;
                $display("ERRO DADOS: TX=%h RX=%h", data_in, data_out);
            end

            if (error !== 1'b0) begin
                erro = 1;
                $display("ERRO PARIDADE: TX=%h RX=%h", data_in, data_out);
            end

            $display(
                "TX=%b (%h) | RX=%b (%h) | done=%b | error=%b",
                data_in,
                data_in,
                data_out,
                data_out,
                done,
                error
            );

        end

        if (!erro)
            $display("\n===== NENHUM ERRO ENCONTRADO =====\n");
        else
            $display("\n===== PELO MENOS UM ERRO ENCONTRADO =====\n");

        $finish;

    end

endmodule