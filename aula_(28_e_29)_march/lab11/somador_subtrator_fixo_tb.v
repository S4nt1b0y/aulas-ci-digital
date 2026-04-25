`timescale 1ns/1ps

// ================================
// Módulo: Soma/Subtração Q4.4 com saturação
// ================================
module q4_4_add_sub_sat (
    input  signed [7:0] a,
    input  signed [7:0] b,
    input  op, // 0 = soma, 1 = subtração
    output reg signed [7:0] result
);

reg signed [8:0] temp;

always @(*) begin
    // Operação com bit extra
    if (op == 1'b0)
        temp = a + b;
    else
        temp = a - b;

    // Saturação
    if (temp > 9'sd127)
        result = 8'sd127;      // +7.9375
    else if (temp < -9'sd128)
        result = -8'sd128;     // -8.0
    else
        result = temp[7:0];
end

endmodule


// ================================
// Testbench
// ================================
module tb_q4_4_add_sub_sat;

reg  signed [7:0] a;
reg  signed [7:0] b;
reg  op;
wire signed [7:0] result;

// Instância do DUT (Device Under Test)
q4_4_add_sub_sat dut (
    .a(a),
    .b(b),
    .op(op),
    .result(result)
);

initial begin
    $display("Tempo | op |     a     |     b     |   result");
    $display("----------------------------------------------------");
    $monitor("%4t  | %b  | %b | %b | %b", $time, op, a, b, result);

    // ============================
    // Teste 1: Soma normal
    // 1.5 + 2.25 = 3.75
    // ============================
    a = 8'b00011000; // 1.5
    b = 8'b00100100; // 2.25
    op = 0;
    #10;

    // ============================
    // Teste 2: Subtração
    // 3.0 - 1.5 = 1.5
    // ============================
    a = 8'b00110000; // 3.0
    b = 8'b00011000; // 1.5
    op = 1;
    #10;

    // ============================
    // Teste 3: Saturação positiva
    // 7.0 + 2.0 -> 7.9375 (máx)
    // ============================
    a = 8'b01110000; // 7.0
    b = 8'b00100000; // 2.0
    op = 0;
    #10;

    // ============================
    // Teste 4: Saturação negativa
    // -7.5 - 2.0 -> -8.0 (mín)
    // ============================
    a = 8'b10001000; // -7.5
    b = 8'b00100000; // 2.0
    op = 1;
    #10;

    $finish;
end

endmodule