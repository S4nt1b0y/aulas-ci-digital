`timescale 1ns/1ps

module primitiva_and_tb;

reg in0;
reg in1;
wire out;

// instância do DUT
primitiva_and and0 (out, in0, in1);


initial begin
    $dumpfile("and.vcd");
    $dumpvars(0, primitiva_and_tb);

    // testa todas combinações
    in0 = 0; in1 = 0; #10;
    in0 = 0; in1 = 1; #10;
    in0 = 1; in1 = 0; #10;
    in0 = 1; in1 = 1; #10;

    // testa valores indefinidos
    in0 = 1'bx; in1 = 0; #10;
    in0 = 0;    in1 = 1'bx; #10;
    in0 = 1'bx; in1 = 1'bx; #10;

    $finish;
end

// monitor
initial begin
    $monitor("t=%0t | in0=%b in1=%b -> out=%b",
              $time, in0, in1, out);
end

endmodule