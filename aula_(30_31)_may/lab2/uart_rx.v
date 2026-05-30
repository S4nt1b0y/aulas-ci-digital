`timescale 1ns / 1ps

module uart_rx #(
    parameter BOUD_RATE = 9600,
    parameter PARIRT_MODE = 0
)(
    input wire clk,
    input wire reset,
    input wire rx,
    output reg [7:0] data_out,
    output reg rx_done,
    output reg error
);

    // Estados da maquina
    localparam IDLE = 3'b000, START = 3'b001, DATA = 3'b010, STOP = 3'b011, DONE = 3'b100, ERROR = 3'b101;
    localparam CLK_PER_BIT_9600 = 16'd5208; // Assumindo 9600 baud rate e 50MHz clock
    localparam CLK_PER_BIT_115200 = 16'd434;  // Assumindo 115200 baud rate e 50MHz clock

    localparam CLK_PER_BIT = (BOUD_RATE == 9600) ? CLK_PER_BIT_9600 : CLK_PER_BIT_115200;
    reg [2:0] state;
    reg [8:0] shift_reg;
    reg [2:0] bit_counter;
    reg [15:0] clk_counter;
	reg enable_counter;
	reg enable_shift;
	reg load_data;
	 
	// Contagem dos ciclos de clock
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_counter <= 16'b0;
        end else if (enable_counter) begin
			if (clk_counter < CLK_PER_BIT - 1) begin
				clk_counter <= clk_counter + 1'b1;
			end else begin
				clk_counter <= 16'b0;
			end
        end else clk_counter <= 16'b0;
    end
	 
    // Registrador de deslocamento
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            shift_reg <= 9'b0;
			data_out <= 8'b0;
        end else if (enable_shift) begin
            shift_reg <= {rx, shift_reg[8:1]};
		end else if (load_data) begin
		    data_out <= shift_reg[8:1];
		end
    end
	 
    // Logica sequencial para determinar o proximo estado
    always @(posedge clk or posedge reset) begin
	    if (reset) begin
		    state <= IDLE;
			bit_counter <= 3'b0;
            error <= 0;
		end else begin
            case (state)
                IDLE: begin
                    if (rx == 0) begin
                        state <= START; // Detecta o bit de inicio
                    end
                end

                START: begin
                    if (clk_counter == CLK_PER_BIT - 1) begin
                        state <= DATA;
                        bit_counter <= 0;
                    end
                end

                DATA: begin
                    if (bit_counter == 7) begin 
                        if (clk_counter == CLK_PER_BIT - 1) begin
                            state <= STOP; // Ultimo bit de dados recebido
                        end
                    end else if (clk_counter == CLK_PER_BIT - 1) begin
                        bit_counter <= bit_counter + 1'b1;
					end
                end

                STOP: begin
				    if (clk_counter == CLK_PER_BIT - 1) begin
                        if(PARIRT_MODE == 1)begin 
                            if (rx == ^(shift_reg[8:1])) begin // Verifica o bit de parada
                                state <= DONE;
                            end else begin
                                state <= ERROR; // Erro na recepcao no STOP bit
                            end
                        end
                        else if(PARIRT_MODE == 2)begin 
                            if (rx == !(^(shift_reg[8:1]))) begin // Verifica o bit de paridade
                                state <= DONE;
                            end else begin
                                state <= ERROR; // Erro na recepcao no STOP bit
                            end
                        end
				    end
                end

                DONE: begin
                    if (clk_counter == CLK_PER_BIT - 1) begin 
                        if(rx == 1'b1) begin
                            state <= IDLE;
                        end else begin
                            state <= ERROR;
                        end
                    end
                        
                end
				
			    ERROR: begin
			        if (clk_counter == CLK_PER_BIT - 1) begin 
                        state <= IDLE;
                        error <= 1;
                    end
			    end

                default: begin
                    // Estado de seguranca
                    state <= IDLE;
                end

            endcase
		end
    end

    // Logica combinacional: Amostragem dos dados
    always @(*) begin
        rx_done = 0;
		enable_counter = 0;
		enable_shift = 0;
		load_data = 0;
        case (state)
            IDLE: begin
            end

            START: begin
			    enable_counter = 1;
            end

            DATA: begin
			    enable_counter = 1;
				enable_shift = (clk_counter == CLK_PER_BIT / 2);
				if ((bit_counter == 7) && (clk_counter == CLK_PER_BIT - 1)) begin
                    load_data = 1;
                end
            end

            STOP: begin
			    enable_counter = 1;
                enable_shift = (clk_counter == CLK_PER_BIT / 2);
            end

            DONE: begin
                enable_counter = 1;
                rx_done = 1;
            end

			ERROR: begin
                enable_counter = 1;
                rx_done = 1;
            end
					 
			default: begin
            end
        endcase
    end

endmodule
