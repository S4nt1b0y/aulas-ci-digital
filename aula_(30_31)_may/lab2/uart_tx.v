`timescale 1ns / 1ps

module uart_tx (
    input wire clk,
    input wire reset,
    input wire [7:0] data_in,
    input wire tx_start,
    output reg tx,
    output reg tx_done
);

    // Estados da maquina
    localparam IDLE = 3'd0, START = 3'd1, DATA = 3'd2, STOP = 3'd3, DONE = 3'd4;
    localparam CLK_PER_BIT = 16'd5208; // Assumindo 9600 baud rate e 50MHz clock

    reg [2:0] state;
    reg [7:0] shift_reg;
    reg [2:0] bit_counter;
    reg [15:0] clk_counter;
	reg load_data;
	reg enable_counter;
	reg enable_shift;
	reg tx_reg;
	 
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
            shift_reg <= 8'b0;
			tx_reg <= 0;
        end else if (enable_shift) begin
			tx_reg <= shift_reg[bit_counter];
		end else if (load_data) begin
		    shift_reg <= data_in;
            tx_reg <= 0;
		end
    end
	 
	// Logica sequencial para determinar o proximo estado
    always @(posedge clk or posedge reset) begin
        if (reset) begin
		    bit_counter <= 1'b0;
			state <= IDLE;
		end else begin
            case (state)
                IDLE: begin
                    if (tx_start && !tx_done) begin
					    state <= START;
						bit_counter <= 1'b0;
				    end
			   end

                START: begin
                    if (clk_counter == CLK_PER_BIT - 1) begin
    			        state <= DATA;
                    end
                end

                DATA: begin
                    if ((bit_counter == 7) && (clk_counter == CLK_PER_BIT - 1)) begin
				        state <= STOP; // Ultimo bit de dados recebido
                    end
				    if (clk_counter == CLK_PER_BIT - 1) begin
                        bit_counter <= bit_counter + 1'b1;
				    end
                end

                STOP: begin
				    if (clk_counter == CLK_PER_BIT - 1) begin
				        state <= DONE;
				    end
                end

                DONE: begin
			        state <= IDLE;
                end

                default: begin
                    // Estado de seguranca
				    state <= IDLE;
                end
            endcase
        end
    end

    always @(*) begin
        tx_done = 0;
		tx = 1;
        enable_counter = 0;
		enable_shift = 0;
		load_data = 0;
        case (state)
            IDLE: begin
            end

            START: begin
			    tx = 0;
				enable_counter = 1;
				load_data = 1;
            end

            DATA: begin
				tx = tx_reg;
				enable_counter = 1;
				enable_shift = 1;
			end

            STOP: begin
                enable_counter = 1;
            end

            DONE: begin
                tx_done = 1; // Sinaliza que a transmissao foi concluida
            end

            default: begin
				tx_done = 0;
				tx = 1;
				enable_counter = 0;
				enable_shift = 0;
				load_data = 0;
            end
        endcase
    end

endmodule