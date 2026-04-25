module register_file (
    input clk,                    //! Clock para sincronização
    input we,                     //! Sinal de habilitação de escrita (Write Enable)
    input [1:0] addr,             //! Endereço do registro a ser acessado (2 bits para 4 registros)
    input [3:0] data_in,          //! Dados de entrada para escrita
    output reg [3:0] data_out     //! Dados de saída do registro selecionado
);
    // 4 registros de 4 bits
    reg [3:0] registers [3:0];
    always @(posedge clk) begin
        if (we) begin
            case (addr)
                2'b00: registers[0] <= data_in;  // Escreve no registro 0
                2'b01: registers[1] <= data_in;  // Escreve no registro 1
                2'b10: registers[2] <= data_in;  // Escreve no registro 2
                2'b11: registers[3] <= data_in;  // Escreve no registro 3
            endcase
        end
    end
    always @(*) begin
        case (addr)
            2'b00: data_out = registers[0];  // Lê o registro 0
            2'b01: data_out = registers[1];  // Lê o registro 1
            2'b10: data_out = registers[2];  // Lê o registro 2
            2'b11: data_out = registers[3];  // Lê o registro 3
            default: data_out = 4'b0000;     // Saída padrão
        endcase
    end
endmodule
