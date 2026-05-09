module top(
    input wire clk,
    input wire inicia_operacao,
    input wire rst,
    input wire [4:0] endereco_ram_in,
    input wire wr_en,
    input wire start,
    input wire cs_ram,
    input wire [7:0] dado_usuario,
    input wire [2:0] operacao_ula,
    input wire [4:0] endereco_rom,
    input wire cs_rom,
    output wire fim,
    output wire [7:0] resultado,
    output wire [7:0] sdado_ram,
    output wire [7:0] result_ula,
    output wire [7:0] sdado_rom
);

    localparam WIDTH=8;

    reg  [3:0] rom_addr;
    wire [7:0] rom_data_out;

    fsm fsm_i (
        .clk(clk),
        .rst(rst),
        .start(start),
        .inicia_operacao(inicia_operacao),
        .fim(fim),
        .op_write(op_write)
    );

    wire wr_en_after = wr_en & !start;

    ram_single RAM_SP (
        .clk(clk),
        .cs(cs_ram),
        .we(wr_en_after),
        .addr(endereco_ram_in),
        .data_in(dado_usuario),
        .data_out(sdado_ram)
    );

    alu #( .WIDTH ( WIDTH ))
    alu_inst
    (
        .opcode    (operacao_ula ),
        .in_a      (sdado_rom ),
        .in_b      (sdado_ram ),
        .alu_out   (result_ula) 
    );

    rom ROM (
        .clk(clk),
        .addr(endereco_rom),
        .cs(cs_rom),
        .data_out(sdado_rom)
    );
    
    reg resultado_ff;

    always @(posedge clk)begin
        if(rst)begin
            resultado_ff = 8'b0;
        end
        else if(op_write) begin 
            resultado_ff = result_ula;
        end
    end

    assign resultado = resultado_ff;
endmodule