`timescale 1ns/1ps

module i2c_master(
    input wire clk,             // Clock principal
    input wire reset,           // Reset sincrono
    input wire start,           // Sinal para iniciar a transmissao
    input wire [6:0] slave_addr,// Endereco do escravo (7 bits)
    input wire rw,              // Modo: 0 = escrita, 1 = leitura
    input wire [7:0] data_in,   // Dados a serem enviados
	output reg [7:0] data_slave,// Dados a serem recebidos
	input wire ack_master,      // ACK a ser enviado pelo mestre
    inout wire scl,             // Linha do clock I2C
    inout wire sda,             // Linha de dados I2C (bidirecional)
    output reg done             // Indica o fim da transmissao
);

    // Parametros para o divisor de clock (ajustar para a frequencia desejada)
    parameter CLK_FREQ = 100_000_000; // Frequencia do clock principal (100 MHz)
    parameter SCL_FREQ = 5_000_000;     // Frequencia do SCL desejada (5 MHz)
    localparam SCL_DIV = CLK_FREQ / (2 * SCL_FREQ); // Contador para gerar SCL

    // Registradores internos
	reg [15:0] clk_counter;      // Contador para dividir o clock principal
    reg [3:0] state, next_state; // Estado atual e proximo estado da FSM
    reg [2:0] bit_index;         // indice do bit sendo transmitido (0 a 7)
    reg [7:0] shift_reg;         // Registrador de deslocamento para transmissao
    reg sda_out;                 // Valor de saida para a linha SDA
    reg scl_out;                 // Valor de saida para a linha SCL
    reg sda_dir;                 // Controle de direcao do SDA: 1 = saida sda, 0 = alta impedancia
    reg scl_dir;                 // Controle de direcao do SCL: 1 = saida scl, 0 = alta impedancia
	reg start_id;                // Identifica que houve uma solicitacao de inicio
    reg scl_last;                // Estado anterior de SCL
	reg check_ack_slave;         // Checa ACK recebido pelo escravo
	 
    // Conexao tri-state para SDA e SCL
    assign sda = sda_dir ? sda_out : 1'bz;
    assign scl = scl_dir ? scl_out : 1'bz;
	 
    // Definicao de estados
    localparam IDLE         = 0;  // Estado ocioso
    localparam START        = 1;  // Geracao da condicao de inicio
    localparam SEND_BIT     = 2;  // Envio de bits (endereco ou dados)
    localparam CHECK_ACK    = 3;  // Verificacao do ACK
	localparam READ_SLAVE   = 4;  // Le dados enviados pelo escravo
	localparam WRITE_ACK    = 5;  // Manda ACK para escravo
    localparam STOP         = 6;  // Geracao da condicao de parada
    localparam DONE         = 7;  // Fim da transmissao

	 // Geracao do clock SCL
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_counter <= 0;
            scl_out <= 1;       // Clock SCL comeca em alto
        end else begin
            if (clk_counter == SCL_DIV - 1) begin
                clk_counter <= 0;
                scl_out <= ~scl_out;   // Alterna o estado do SCL
            end else begin
                clk_counter <= clk_counter + 1;
            end
        end
    end	 
	 
	 // Sincronizacao de SCL e SDA no clock do sistema
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            scl_last <= 1;
        end else begin
            scl_last <= scl_out;
        end
    end
	 
	 // Identifica inicio do controle
	 always @(posedge clk or posedge reset) begin
	     if (reset) begin
		      start_id <= 0;
		  end else begin
		      if (start == 1) begin
				    start_id <= 1;
				end else if (start_id == 1 && state != IDLE) begin
			       start_id <= 0;
			   end
		  end
    end
				 
    // Logica sequencial: Transicao de estado
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // Logica combinacional: Proximo estado
    always @(*) begin
        // Definir proximo estado como padrao
        next_state = state;
        case (state)
            IDLE: begin
                if (start_id) begin
                    next_state = START;
                end
            end

            START: begin
				    if (scl_last && !scl_out) next_state = SEND_BIT;  // Muda de estado na borda de descida
            end

            SEND_BIT: begin
                if (scl_last && !scl_out && bit_index == 0) begin
                    next_state = CHECK_ACK;
                end
            end

            CHECK_ACK: begin
                if (scl_last && !scl_out) begin
                    if (check_ack_slave) begin // ACK recebido
						      if (rw == 0) begin
								    next_state = SEND_BIT;
							   end else begin
								    next_state = READ_SLAVE;
								end
                    end else begin
                        next_state = STOP; // NACK ou erro
                    end
                end
            end
				
				READ_SLAVE: begin
				    if (scl_last && !scl_out && bit_index == 0) next_state = WRITE_ACK;
				end
				
				WRITE_ACK: begin
				    if (scl_last && !scl_out) begin
					     if (ack_master == 0) begin
					         next_state = READ_SLAVE;
						  end else begin
						      next_state = STOP;
						  end
					end
				end

            STOP: begin
                if (scl_last && !scl_out) next_state = DONE;
            end

            DONE: begin
                if (scl_last && !scl_out) next_state = IDLE;
            end
				
				default: next_state = IDLE;
        endcase
    end

    // Logica sequencial: Atualizacao dos sinais
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Inicializacao em caso de reset
            sda_out <= 1;      // SDA comeca em nivel alto
            sda_dir <= 0;      // SDA em alta impedancia
            scl_dir <= 0;      // SCL inicialmente desativado
            done <= 0;         // Transmissao nao concluida
			check_ack_slave <= 0;
            shift_reg <= 8'b0;
            bit_index <= 7;
			data_slave <= 8'b0;
        end else begin
            case (state)
                IDLE: begin
                    // Estado ocioso: Aguardando o sinal de inicio
                    sda_out <= 1;      // SDA comeca em nivel alto
                    sda_dir <= 0;      // SDA em alta impedancia
                    scl_dir <= 0;      // SCL inicialmente desativado
                    done <= 0;         // Transmissao nao concluida
				    check_ack_slave <= 0;
                    shift_reg <= 8'b0;
                    bit_index <= 7;
				    data_slave <= 8'b0;
                end

                START: begin
                    // Condicao de inicio: SDA vai para baixo enquanto SCL esta alto
                    if (scl_out == 1) sda_out <= 0;
                    sda_dir <= 1; // Controla a linha SDA
					scl_dir <= 1; // Controla a linha SCL
                    shift_reg <= {slave_addr, rw}; // Combina endereco e RW no registrador de deslocamento
                    bit_index <= 7; // Configura o indice para 8 bits (endereco + RW)
                end

                SEND_BIT: begin
					sda_out <= shift_reg[bit_index];
                    sda_dir <= 1; // Controla a linha SDA
                    if (scl_last && !scl_out) begin
                        if (bit_index > 0) begin
                            bit_index <= bit_index - 1'd1; // Proximo bit
                        end
                    end
                end

                CHECK_ACK: begin
                    sda_dir <= 0; // Libera a linha SDA para o receptor
					bit_index <= 7;
					if (!scl_last && scl_out) begin
                        if (sda == 0) begin // ACK recebido
                            check_ack_slave <= 1;
							if (rw == 0) shift_reg <= data_in;
                        end else begin
                            check_ack_slave <= 0; // NACK ou erro
						end
                    end else if (scl_last && !scl_out) begin
						check_ack_slave <= 0;
					end
                end
					 
				READ_SLAVE: begin
                    sda_dir <= 0; // Libera a linha SDA
   				    if (!scl_last && scl_out) data_slave[bit_index] <= sda;
                    if (scl_last && !scl_out) begin
                        if (bit_index > 0) begin
                            bit_index <= bit_index - 1'd1; // Proximo bit
                        end
                    end
					 end
					 
				WRITE_ACK: begin
				    sda_dir <= 1;
					bit_index <= 7;
					sda_out <= ack_master;
				end

                STOP: begin
					// Condicao de parada: SDA vai para alto enquanto SCL esta alto
                    if (scl_out == 0 && next_state == STOP) begin
					    sda_dir <= 1; // Coloca a linha para condicao de parada
					    sda_out <= 0;
					end else if (scl_out == 1) begin
                        sda_out <= 1;
					    sda_dir <= 0; // Libera a linha SDA
					end
                end

                DONE: begin
                    done <= 1;
                    sda_out <= 1;
                    sda_dir <= 0; // Libera a linha SDA
					scl_dir <= 0; // Libera a linha SCL
                end
            endcase
        end
    end
endmodule