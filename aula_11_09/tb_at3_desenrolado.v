`timescale 1ns/1ps

module tb_at3_desenrolado;
    reg clk;
    reg [7:0] X;
    wire [7:0] XPower;

    integer errors;
    integer cycle;
    reg [7:0] delay0;
    reg [7:0] delay1;

    x3_curto dut (
        .XPower(XPower),
        .X(X),
        .clk(clk)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    function [7:0] cube8;
        input [7:0] value;
        begin
            cube8 = value * value * value;
        end
    endfunction

    task apply_and_check;
        input [7:0] value;
        begin
            X = value;
            @(posedge clk);
            #1;

            if (cycle >= 2 && XPower !== cube8(delay1)) begin
                $error("XPower=%0d, esperado=%0d para X atrasado=%0d",
                       XPower, cube8(delay1), delay1);
                errors = errors + 1;
            end

            delay1 = delay0;
            delay0 = value;
            cycle = cycle + 1;
        end
    endtask

    initial begin
        $dumpfile("tb_at3_desenrolado.vcd");
        $dumpvars(0, tb_at3_desenrolado);

        errors = 0;
        cycle = 0;
        delay0 = 8'd0;
        delay1 = 8'd0;
        X = 8'd0;

        apply_and_check(8'd1);
        apply_and_check(8'd2);
        apply_and_check(8'd3);
        apply_and_check(8'd6);
        apply_and_check(8'd9);
        apply_and_check(8'd12);

        if (errors == 0)
            $display("tb_at3_desenrolado: PASS");
        else
            $display("tb_at3_desenrolado: FAIL com %0d erro(s)", errors);

        $finish;
    end
endmodule
