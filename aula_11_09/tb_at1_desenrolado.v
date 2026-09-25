`timescale 1ns/1ps

module tb_at1_desenrolado;
    reg clk;
    reg [7:0] X;
    wire [7:0] XPower;

    integer errors;
    reg [7:0] previous_x;

    x3_longo dut (
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

            if (XPower !== cube8(previous_x)) begin
                $error("XPower=%0d, esperado=%0d para X anterior=%0d",
                       XPower, cube8(previous_x), previous_x);
                errors = errors + 1;
            end

            previous_x = value;
        end
    endtask

    initial begin
        $dumpfile("tb_at1_desenrolado.vcd");
        $dumpvars(0, tb_at1_desenrolado);

        errors = 0;
        X = 8'd2;

        @(posedge clk);
        #1;
        previous_x = X;

        apply_and_check(8'd3);
        apply_and_check(8'd4);
        apply_and_check(8'd5);
        apply_and_check(8'd10);

        if (errors == 0)
            $display("tb_at1_desenrolado: PASS");
        else
            $display("tb_at1_desenrolado: FAIL com %0d erro(s)", errors);

        $finish;
    end
endmodule
