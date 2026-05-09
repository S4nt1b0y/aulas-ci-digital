module register_file #(
    parameter DATA_WIDTH = 32, // 32-bits de dados
    parameter ADDR_WIDTH = 5,  // 5-bits de endereço (até 32 registros)
    parameter REG_COUNT  = 32  // 32 registros
)(
    input  wire                     clk,
    input  wire                     wr_en,
    input  wire [ADDR_WIDTH-1:0]    wr_addr,
    input  wire [DATA_WIDTH-1:0]    wr_data,
    input  wire [ADDR_WIDTH-1:0]    rd_addr1,
    input  wire [ADDR_WIDTH-1:0]    rd_addr2,
    output wire [DATA_WIDTH-1:0]    rd_data1,
    output wire [DATA_WIDTH-1:0]    rd_data2,
    output reg                      wr_ack
);

    // Memória RAM implementando o banco de registradores
    reg [DATA_WIDTH-1:0] registers [0:REG_COUNT-1];

    // Escrita síncrona
    always @(posedge clk) begin
        if (wr_en) begin
            registers[wr_addr] <= wr_data;
        end
    end

    // Leitura combinacional (assíncrona)
    assign rd_data1 = registers[rd_addr1];
    assign rd_data2 = registers[rd_addr2];

endmodule