module fsm (
    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire inicia_operacao,

    output reg fim,
    output reg op_write
);

    parameter IDLE  = 2'b00;
    parameter EXEC  = 2'b01;
    parameter WRITE = 2'b10;

    reg [1:0] estado_atual;
    reg [1:0] proximo_estado;


    always @(posedge clk or posedge rst) begin
        if (rst)
            estado_atual <= IDLE;
        else
            estado_atual <= proximo_estado;
    end

    always @(*) begin

        proximo_estado = estado_atual;

        fim      = 1'b0;
        op_write = 1'b0;

        case (estado_atual)
            IDLE: begin
                fim = 1'b0;
                if (start && inicia_operacao)
                    proximo_estado = EXEC;
                else
                    proximo_estado = IDLE;
            end
            EXEC: proximo_estado = WRITE;
            WRITE: begin
                op_write = 1'b1;
                fim = 1'b1;
                proximo_estado = IDLE;
            end
            default: begin
                proximo_estado = IDLE;
                fim      = 1'b0;
                op_write = 1'b0;

            end

        endcase
    end

endmodule