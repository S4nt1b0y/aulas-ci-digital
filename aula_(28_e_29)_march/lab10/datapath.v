module datapath 
#(
    parameter WIDTH = 4

)
(
    input wire clk,
    input wire rst,
    input wire [WIDTH-1:0] datain,
    input wire [2:0] opcode,
    input wire sel_regfile_input,
    input wire [1:0] regfile_addr,
    input wire sel_isOperand_A,
    input wire write_enable,
    output wire [WIDTH-1:0] alu_result
);


    wire[WIDTH-1:0] operandA;
    wire [WIDTH-1:0] regA_datain;

    register_4bits regA(
        .clk(clk),        // Sinal de clock
        .reset(rst),      // Sinal de reset (ativo em nível alto)
        .d(regA_datain),  // Entrada de 4 bits
        .q(operandA)
    );

    wire [WIDTH-1:0] operandB;
    wire [WIDTH-1:0] regB_datain;

    register_4bits regB(
        .clk(clk),        // Sinal de clock
        .reset(rst),      // Sinal de reset (ativo em nível alto)
        .d(regB_datain),  // Entrada de 4 bits
        .q(operandB)
    );

     ula ula_i(
        .A(operandA),
        .B(operandB),
        .seletor(opcode),
        .resultado(alu_result)
    );

    wire [WIDTH-1:0] regfile_input;

    mux2x1_4bits regfile_mux_input(
        .in0(datain),      //! Entrada 0 (4 bits)
        .in1(alu_result),      //! Entrada 1 (4 bits)
        .sel(sel_regfile_input),            //! Sinal de seleção (1 bit)
        .out(regfile_input)       //! Saída do multiplexador (4 bits)
    );

    wire [WIDTH-1:0] regfile_output;

    register_file reg_file(
        .clk(clk),                         //! Clock para sincronização
        .we(write_enable),                 //! Sinal de habilitação de escrita (Write Enable)
        .addr(regfile_addr),               //! Endereço do registro a ser acessado (2 bits para 4 registros)
        .data_in(regfile_input),           //! Dados de entrada para escrita
        .data_out(regfile_output)          //! Dados de saída do registro selecionado
    );


    demux1x2_4bits operands_input(
    .in(regfile_output),    // Entrada de 4 bits
    .sel(sel_isOperand_A),          // Sinal de seleção (1 bit)
    .out0(regB_datain),  // Saída 0 (4 bits)
    .out1(regA_datain)   // Saída 1 (4 bits)
);


endmodule