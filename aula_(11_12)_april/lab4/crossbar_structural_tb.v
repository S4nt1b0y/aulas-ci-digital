`timescale 1ns/1ps

module crossbar_structural_tb;

    reg in1;
    reg in2;
    reg select;

    wire out1;
    wire out2;

    crossbar_structural dut (
        .in1(in1),
        .in2(in2),
        .select(select),
        .out1(out1),
        .out2(out2)
    );

    initial begin
        $monitor("select=%b | in1=%b | in2=%b | out1=%b | out2=%b",
                   select, in1, in2, out1, out2);

        in1 = 0; in2 = 1; select = 0; #10;

        in1 = 1; in2 = 0; select = 0; #10;

        in1 = 0; in2 = 1; select = 1; #10;

        in1 = 1; in2 = 0; select = 1; #10;

        $finish;
    end

endmodule