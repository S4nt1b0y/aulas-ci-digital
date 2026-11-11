`timescale 1ns/1ps

module tb_at2_enrolado;
    localparam N = 5;

    reg clk;
    reg start;
    reg [7:0] X;
    wire [7:0] XPower;
    wire finished;

    integer errors;

    x3_enrolado_param #(.N(N)) dut (
        .XPower(XPower),
        .finished(finished),
        .X(X),
        .clk(clk),
        .start(start)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    function [7:0] pow8;
        input [7:0] base;
        input integer exponent;
        integer i;
        begin
            pow8 = 8'd1;
            for (i = 0; i < exponent; i = i + 1)
                pow8 = pow8 * base;
        end
    endfunction

    task run_case;
        input [7:0] value;
        reg [7:0] expected;
        begin
            expected = pow8(value, N);

            @(negedge clk);
            X = value;
            start = 1'b1;

            @(posedge clk);
            #1;
            start = 1'b0;

            wait (finished === 1'b1);
            #1;

            if (XPower !== expected) begin
                $error("XPower=%0d, esperado=%0d para X=%0d e N=%0d",
                       XPower, expected, value, N);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("tb_at2_enrolado.vcd");
        $dumpvars(0, tb_at2_enrolado);

        errors = 0;
        start = 1'b0;
        X = 8'd0;

        run_case(8'd2);
        run_case(8'd3);
        run_case(8'd4);

        if (errors == 0)
            $display("tb_at2_enrolado: PASS");
        else
            $display("tb_at2_enrolado: FAIL com %0d erro(s)", errors);

        $finish;
    end
endmodule
