`timescale 1ns / 1ps

module tb_uart_tx;

    reg clk;
    reg reset;
    reg [7:0] data_in;
    reg tx_start;
    wire tx;
    wire tx_done;

    uart_tx #(.BOUD_RATE(9600), .PARIRT_MODE(1)) uut (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .tx_start(tx_start),
        .tx(tx),
        .tx_done(tx_done)
    );

    integer counter_clk, i;
	reg [7:0] data_tx;

    // Geracao de clock
    always #10 clk = ~clk; // Clock de 50 MHz

    // Variavel auxiliar para o baud rate
    localparam BAUD_PERIOD = 104160; // 1/9600 s em nanossegundos

	 always @(posedge clk) begin
	    if (uut.state == 3'd2) begin
		    counter_clk = counter_clk + 1;
			if (counter_clk == BAUD_PERIOD / 20) begin // OBS: 20 (em nanosegundos) = 1/50MHz - periodo do clock
			    data_tx = {tx, data_tx[7:1]};
				counter_clk = 0;
			end
		end else begin
			counter_clk = 0;
		end
	end
	 
    initial begin
        // Inicializa os sinais
		data_tx = 8'b0;
        clk = 0;
        reset = 1;
        tx_start = 0;
        data_in = 8'h00;

        $display("Iniciando o Testbench do UART TX...");

        // Libera o reset apos alguns ciclos de clock
        #20 reset = 0;
        #BAUD_PERIOD;

        // Teste 1: Envia o dado 8'hA5
        send_byte(8'hA5);

        // Teste 2: Reinicia durante a transmissao
        #50 reset = 1;
        #20 reset = 0;
		#BAUD_PERIOD;

        // Teste 3: Envia multiplos dados consecutivamente
		for (i = 0; i <= 255; i = i + 1) send_byte(i);

        // Finaliza a simulacao
        $display("Testbench concluido!");
        $finish;
    end

    // Tarefa para enviar um byte
    task send_byte(input [7:0] byte);
        begin
            data_in = byte;
            #BAUD_PERIOD tx_start = 1;
            #BAUD_PERIOD tx_start = 0;

            // Aguarda a transmissao completar
            wait (tx_done);

            // Verifica o tempo de transmissao
            #(5 * BAUD_PERIOD); 
			#(BAUD_PERIOD / 2);	// Deslocar do pulso de clk no teste continuo			
				
			if (data_in == data_tx) $display("%t: Dado %h transmitido com sucesso. Valor recebido %h.", $time, data_in, data_tx);
			else $display("%t: Dado %h transmitido com erro. Valor recebido %h.", $time, data_in, data_tx);
				
        end
    endtask

endmodule
