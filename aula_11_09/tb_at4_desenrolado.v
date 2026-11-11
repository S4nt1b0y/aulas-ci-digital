`timescale 1ns/1ps

module tb_at4_desenrolado;
    localparam lengthX = 8;

    reg clk;
    reg rst;
    reg [lengthX-1:0] x;
    wire [3*lengthX-1:0] polinomio;

    integer errors;

    x3x2x_notFull #(.lengthX(lengthX)) dut (
        .clk(clk),
        .x(x),
        .polinomio(polinomio),
        .rst(rst)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    function [3*lengthX-1:0] polynomial;
        input [lengthX-1:0] value;
        begin
            polynomial = (value * value * value) + (value * value) + value;
        end
    endfunction

    task reset_dut;
        begin
            @(negedge clk);
            rst = 1'b1;
            x = 0;
            @(posedge clk);
            #1;

            if (polinomio !== 0) begin
                $error("polinomio deveria zerar no reset, mas vale %0d", polinomio);
                errors = errors + 1;
            end

            @(negedge clk);
            rst = 1'b0;
        end
    endtask

    task run_constant_case;
        input [lengthX-1:0] value;
        reg [3*lengthX-1:0] expected;
        begin
            expected = polynomial(value);

            x = value;
            repeat (4) @(posedge clk);
            #1;

            if (polinomio !== expected) begin
                $error("polinomio=%0d, esperado=%0d para x=%0d",
                       polinomio, expected, value);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("tb_at4_desenrolado.vcd");
        $dumpvars(0, tb_at4_desenrolado);

        errors = 0;
        rst = 1'b0;
        x = 0;

        reset_dut();
        run_constant_case(8'd2);
        run_constant_case(8'd3);
        run_constant_case(8'd7);
        run_constant_case(8'd10);

        if (errors == 0)
            $display("tb_at4_desenrolado: PASS");
        else
            $display("tb_at4_desenrolado: FAIL com %0d erro(s)", errors);

        $finish;
    end
endmodule
