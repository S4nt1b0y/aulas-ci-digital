`timescale 1ns/1ps

module tb_goldschmidt_rolled;

    reg         clk;
    reg         clrn;
    reg         start;
    reg  [31:0] a;
    reg  [31:0] b;

    wire [31:0] q;
    wire        busy;
    wire        ready;
    wire [2:0]  count;
    wire [31:0] yn;

    // DUT
    goldschmidt_rolled dut (
        .a     (a),
        .b     (b),
        .start (start),
        .clk   (clk),
        .clrn  (clrn),
        .q     (q),
        .busy  (busy),
        .ready (ready),
        .count (count),
        .yn    (yn)
    );

    // Clock de 100 MHz
    // Período = 10 ns
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // Estímulos
    initial begin
        $dumpfile("tb_at3_enrolado.vcd");
        $dumpvars(0, tb_goldschmidt_rolled);
        // Estado inicial
        clrn  = 1'b0;
        start = 1'b0;
        a     = 32'd0;
        b     = 32'd0;

        // Reset
        #20;
        clrn = 1'b1;

        #10;

        // Exemplo:
        // a = 0.75
        // b = 0.50
        //
        // Considerando formato fracionário Q0.32:
        // 0.75 * 2^32 = 0xC0000000
        // 0.50 * 2^32 = 0x80000000

        a = 32'hC0000000;
        b = 32'h80000000;

        // Pulso de start por 1 ciclo
        @(posedge clk);
        start = 1'b1;

        @(posedge clk);
        start = 1'b0;

        // Espera o resultado ficar pronto
        wait (ready == 1'b1);

        #1;

        $display("--------------------------------");
        $display("Resultado:");
        $display("a     = 0x%08h", a);
        $display("b     = 0x%08h", b);
        $display("q     = 0x%08h", q);
        $display("yn    = 0x%08h", yn);
        $display("count = %0d", count);
        $display("--------------------------------");

        #20;

        $finish;
    end

    // Monitor opcional
    initial begin
        $monitor(
            "time=%0t | start=%b busy=%b ready=%b count=%0d | q=%h yn=%h",
            $time,
            start,
            busy,
            ready,
            count,
            q,
            yn
        );
    end

endmodule