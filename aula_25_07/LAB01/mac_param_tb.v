`timescale 1ns/1ps

module tb_mac_param;

    localparam DATA_WIDTH = 8;
    localparam NUM_TERMS  = 16;
    localparam ACC_WIDTH  = 2*DATA_WIDTH + $clog2(NUM_TERMS);

    reg clk;
    reg rst_n;
    reg start;
    reg valid;
    reg [DATA_WIDTH-1:0] a;
    reg [DATA_WIDTH-1:0] b;

    wire busy;
    wire done;
    wire [ACC_WIDTH-1:0] result;

    //=========================================================
    // Instância do DUT
    //=========================================================
    mac_param #(
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_TERMS(NUM_TERMS)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .valid(valid),
        .a(a),
        .b(b),
        .busy(busy),
        .done(done),
        .result(result)
    );

    //=========================================================
    // Clock (100 MHz)
    //=========================================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //=========================================================
    // Variável de referência
    //=========================================================
    integer i;
    integer expected;

    //=========================================================
    // Estímulos
    //=========================================================
    initial begin

        rst_n = 0;
        start = 0;
        valid = 0;
        a = 0;
        b = 0;
        expected = 0;

        // Reset
        #20;
        rst_n = 1;

        // Inicia operação
        @(posedge clk);
        start <= 1;

        @(posedge clk);
        start <= 0;

        // Envia NUM_TERMS multiplicações
        for(i=0; i<NUM_TERMS; i=i+1) begin
            @(posedge clk);

            valid <= 1;
            a <= i;
            b <= 2;

            expected = expected + (i*2);
        end

        @(posedge clk);
        valid <= 0;

        // Espera término
        wait(done);

        #10;

        $display("-------------------------------------");
        $display("Resultado esperado = %0d", expected);
        $display("Resultado obtido   = %0d", result);

        if(result == expected)
            $display("TESTE PASSOU!");
        else
            $display("TESTE FALHOU!");

        $display("-------------------------------------");

        #20;
        $finish;
    end

    //=========================================================
    // Monitor
    //=========================================================
    initial begin
        $monitor("[%0t] start=%b valid=%b busy=%b done=%b a=%0d b=%0d result=%0d",
                  $time, start, valid, busy, done, a, b, result);
    end

endmodule