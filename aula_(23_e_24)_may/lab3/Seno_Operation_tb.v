`timescale 1ns/1ps

module tb_Seno_Operation;

    // Entradas
    reg [7:0] phase;

    // Saídas
    wire [15:0] seno;

    // Instancia o DUT (Device Under Test)
    Seno_Operation dut (
        .phase(phase),
        .seno(seno)
    );

    // Task para facilitar os testes
    task testar;
        input [7:0] fase;
        input [15:0] esperado;
        begin
            phase = fase;
            #10;

            if (seno === esperado)
                $display("OK  | phase = %d | seno = %h", fase, seno);
            else
                $display("ERRO| phase = %d | esperado = %h | obtido = %h",
                         fase, esperado, seno);
        end
    endtask

    initial begin

        $display("===== INICIO DOS TESTES =====");

        // Angulos validos
        testar(8'd0,   16'h0000); // 0°
        testar(8'd10,  16'h1639); // 10°
        testar(8'd20,  16'h2BC7); // 20°
        testar(8'd30,  16'h4000); // 30°
        testar(8'd40,  16'h5247); // 40°
        testar(8'd50,  16'h620C); // 50°
        testar(8'd60,  16'h6ED9); // 60°
        testar(8'd70,  16'h7848); // 70°
        testar(8'd80,  16'h7E0E); // 80°
        testar(8'd90,  16'h8000); // 90°

        // Valores invalidos -> devem retornar 0°
        testar(8'd5,   16'h0000);
        testar(8'd15,  16'h0000);
        testar(8'd25,  16'h0000);
        testar(8'd33,  16'h0000);
        testar(8'd99,  16'h0000);
        testar(8'd120, 16'h0000);
        testar(8'd255, 16'h0000);

        $display("===== FIM DOS TESTES =====");

        $finish;
    end

endmodule