`timescale 1ns/1ps

module mux2x1_rtl_tb;

    reg in1, in2, select;

    wire out1, out2, out3;

    // Instanciação do módulo (DUT - Device Under Test)
    mux2x1_rtl_1 uut1 (
        .in1(in1),
        .in2(in2),
        .select(select),
        .out(out1)
    );

    mux2x1_rtl_2 uut2 (
        .in1(in1),
        .in2(in2),
        .select(select),
        .out(out2)
    );
    mux2x1_rtl_3 uut3 (
        .in1(in1),
        .in2(in2),
        .select(select),
        .out(out3)
    );

    // Geração de estímulos
    initial begin
        // Monitor para acompanhar os valores
        $monitor("Tempo=%0t | select=%b | in1=%b | in2=%b | out1=%b | out2=%b | out3=%b",
                  $time, select, in1, in2, out1, out2, out3);

        // Testes
        in1 = 0; in2 = 0; select = 0; #10;
        in1 = 0; in2 = 1; select = 0; #10;
        in1 = 1; in2 = 0; select = 0; #10;
        in1 = 1; in2 = 1; select = 0; #10;

        in1 = 0; in2 = 0; select = 1; #10;
        in1 = 0; in2 = 1; select = 1; #10;
        in1 = 1; in2 = 0; select = 1; #10;
        in1 = 1; in2 = 1; select = 1; #10;

        // Finaliza simulação
        $finish;
    end

endmodule