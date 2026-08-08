`timescale 1ns/1ps

module x3_curto_tb;

    // Sinais do DUT
    reg        clk;
    reg  [7:0] X;
    wire [7:0] XPower;

    // Instância do circuito
    x3_curto dut (
        .XPower(XPower),
        .X(X),
        .clk(clk)
    );

    // Geração do clock: período de 10 ns
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        $sdf_annotate("delays.sdf", x3_curto_tb.dut, ,"sdf.log","MAXIMUM");
    end


    // Estímulos
    initial begin
        $display("=================================================");
        $display(" Testbench - x3_curto");
        $display("=================================================");

        X = 8'd0;

        // Aguarda alguns ciclos para inicialização
        repeat (2) @(posedge clk);

        // Testes
        X = 8'd2;
        @(posedge clk);

        X = 8'd3;
        @(posedge clk);

        X = 8'd4;
        @(posedge clk);

        X = 8'd5;
        @(posedge clk);

        X = 8'd10;
        @(posedge clk);

        X = 8'd20;
        @(posedge clk);

        // Aguarda o pipeline terminar
        repeat (3) @(posedge clk);

        $display("=================================================");
        $display(" Fim da simulação");
        $display("=================================================");

        $finish;
    end

    // Monitoramento
    always @(posedge clk) begin
        #1;
        $display("Tempo=%0t ns | X=%0d | XPower=%0d",
                 $time, X, XPower);
    end

endmodule