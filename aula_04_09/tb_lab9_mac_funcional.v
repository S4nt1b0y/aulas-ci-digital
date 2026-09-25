`timescale 1ns/1ps

module tb_lab9_mac_funcional;
    localparam DATA_WIDTH = 8;
    localparam NUM_TERMS  = 2048;
    localparam ACC_WIDTH  = 2*DATA_WIDTH + $clog2(NUM_TERMS);

    localparam [ACC_WIDTH-1:0] ACC_PRE = 27'd67108863;
    localparam [ACC_WIDTH-1:0] ACC_POS = 27'd67108864;

    reg clk;
    reg rst_n;
    reg start;
    reg valid;
    reg [DATA_WIDTH-1:0] a;
    reg [DATA_WIDTH-1:0] b;

    wire busy;
    wire done;
    wire [ACC_WIDTH-1:0] result;

    integer ops;
    real test_time_us;
    real cost_per_die_usd;

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

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk; // ATE em 100 MHz: periodo de 10 ns
    end

    task apply_mac;
        input [DATA_WIDTH-1:0] ta;
        input [DATA_WIDTH-1:0] tb;
        begin
            @(negedge clk);
            valid = 1'b1;
            a = ta;
            b = tb;
            @(posedge clk);
            #1;
            ops = ops + 1;
        end
    endtask

    integer i;

    initial begin
        rst_n = 1'b0;
        start = 1'b0;
        valid = 1'b0;
        a = 8'd0;
        b = 8'd0;
        ops = 0;

        repeat (2) @(posedge clk);
        rst_n = 1'b1;

        @(negedge clk);
        start = 1'b1;
        @(posedge clk);
        #1;
        start = 1'b0;

        for (i = 0; i < 1031; i = i + 1) begin
            apply_mac(8'd255, 8'd255);
        end

        apply_mac(8'd237, 8'd14);
        apply_mac(8'd255, 8'd254);

        if (result !== ACC_PRE) begin
            $display("ERRO: ACC_pre esperado=%0d obtido=%0d", ACC_PRE, result);
            $finish;
        end

        $display("ACC_pre atingido apos %0d operacoes: %0d", ops, result);

        apply_mac(8'd1, 8'd1);

        if (result !== ACC_POS) begin
            $display("ERRO: ACC_pos esperado=%0d obtido=%0d", ACC_POS, result);
            $finish;
        end

        test_time_us = ops * 0.010;
        cost_per_die_usd = (test_time_us * 1.0e-6) * (500.0 / 3600.0) / 32.0;

        $display("ACC_pos atingido apos A=1, B=1: %0d", result);
        $display("Operacoes ate observar a condicao: %0d", ops);
        $display("Tempo funcional no ATE: %.3f us", test_time_us);
        $display("Custo por die: US$ %.12f", cost_per_die_usd);
        $finish;
    end
endmodule
