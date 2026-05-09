module top_tb();

    reg [4:0] endereco_saida;
    reg we_resultado;
    reg [4:0] enderecoA;
    reg [4:0] enderecoB;
    reg clk;
    reg [7:0] dado_in;
    reg we_mem_in;
    reg [2:0] opcode;
    wire [7:0] saida;
    wire [7:0] sdadoA;
    wire [7:0] sdadoB;
    wire [7:0] s_ula;

    reg cs = 1;
    

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end



    top dut(
        .endereco_saida(endereco_saida),
        .we_resultado(we_resultado),
        .enderecoA(enderecoA),
        .enderecoB(enderecoB),
        .clk(clk),
        .cs(cs),
        .dado_in(dado_in),
        .we_mem_in(we_mem_in),
        .opcode(opcode),
        .saida(saida),
        .sdadoA(sdadoA),
        .sdadoB(sdadoB),
        .s_ula(s_ula)
    );


endmodule