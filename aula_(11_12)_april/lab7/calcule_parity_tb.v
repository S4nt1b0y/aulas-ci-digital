`timescale 1ns/1ps

module calcule_parity_tb;

    reg [3:0] a;
    wire res;

    calcule_parity dut (
        .a(a),
        .res(res)
    );
    
    integer i;

    initial begin
        $display("Iniciando testes...");

        for (i = 0; i < 16; i++) begin
            a = i;
            #1;

            if (res !== ^a) begin
                $display("ERRO: a = %b | res = %b | esperado = %b", a, res, ^a);
            end else begin
                $display("OK: a = %b | res = %b", a, res);
            end
        end

        $display("Testes finalizados.");
        $finish;
    end

endmodule