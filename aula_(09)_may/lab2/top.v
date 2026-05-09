module top(
    input wire [4:0] endereco_saida,
    input wire we_resultado,
    input wire [4:0] enderecoA,
    input wire [4:0] enderecoB,
    input wire clk,
    input wire cs,
    input wire [7:0] dado_in,
    input wire we_mem_in,
    input wire [2:0] opcode,
    output wire [7:0] saida,
    output wire [7:0] sdadoA,
    output wire [7:0] sdadoB,
    output wire [7:0] s_ula
);

    localparam WIDTH=8;

    ram_single RAM_SP (
        .clk(clk),
        .cs(cs),
        .we(we_resultado),
        .addr(endereco_saida),
        .data_in(s_ula),
        .data_out(saida)
    );

    ram_dual RAM_DP (
        .clk(clk),
        .cs(cs),
        .addr_wr_a(enderecoA),
        .addr_rd_b(enderecoB),
        .data_wr_a(dado_in),
        .we_a(we_mem_in),
        .data_rd_a(sdadoA),
        .data_rd_b(sdadoB)
    );

    alu #( .WIDTH ( WIDTH ))
    alu_inst
    (
        .opcode    (opcode ),
        .in_a      (sdadoA ),
        .in_b      (sdadoB ),
        .alu_out   (s_ula) 
    );

endmodule