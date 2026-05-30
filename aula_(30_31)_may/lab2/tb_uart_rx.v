`timescale 1ns / 1ps

module tb_uart_rx;

    reg clk;
    reg reset;
    reg rx;
    wire [7:0] data_out;
    wire rx_done;
    reg clk_rx_tb;
    wire error;
	 
    // Parametros para a simulacao
    localparam CLK_PERIOD = 20; // Periodo do clock em ns (50 MHz)
    localparam CLK_PER_BIT = 5208; // Ciclos de clock por bit (9600 baud rate)

    // Instanciacao do modulo UART RX
    uart_rx #(.BOUD_RATE(9600), .PARIRT_MODE(1))
    uut (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .data_out(data_out),
        .rx_done(rx_done),
        .error(error)
    );

    // Geracao de clock
    always #(CLK_PERIOD / 2) clk = ~clk;
	 
	always #(CLK_PER_BIT * 10) clk_rx_tb = ~clk_rx_tb; // em ns

    integer i, r_ok, r_nok;

    initial begin
        i = 0;
        // Inicializa os sinais
        clk = 0;
        clk_rx_tb = 0;
        reset = 1;
        rx = 1; // Linha RX em repouso

        // Libera o reset apos alguns ciclos
        #(2 * CLK_PERIOD);
        reset = 0;

        rx = 1'b1;
        #(2 * CLK_PER_BIT * CLK_PERIOD);

        // Teste 1: Envia multiplos dados consecutivamente
        r_ok = 0;
        r_nok = 0;
		for (i = 0; i <= 255; i = i + 1) begin 
            send_byte(i);
            wait(rx_done);
            if ((data_out == i) && (uut.state == 4)) begin
                $display("Time = %0t: Teste concluido com sucesso! Dado enviado: %2h. Dado recebido: %h", $time, i, data_out);
                r_ok = r_ok + 1;
            end else begin
                $display("Time = %0t: Teste falhou! Dado enviado: %2h. Dado recebido: %h", $time, i, data_out);
                r_nok = r_nok + 1;
            end
            rx = 1'b1;
            #(2 * CLK_PER_BIT * CLK_PERIOD);
        end

   		$display("Dados recebidos de forma correta: %3d/256", r_ok);
		$display("Dados recebidos de forma erronea: %3d/256", r_nok);

        rx = 1'b1;
        #(2 * CLK_PER_BIT * CLK_PERIOD);

        // Teste 2: Envia multiplos dados consecutivamente com erro no stop bit
        r_ok = 0;
        r_nok = 0;
		for (i = 0; i <= 255; i = i + 1) begin 
            send_byte_with_error(i);
            wait(rx_done);
            if ((data_out == i) && (error)) begin
                $display("Time = %0t: Teste concluido com sucesso! Dado enviado: %2h. Dado recebido: %h", $time, i, data_out);
                r_ok = r_ok + 1;
            end else begin
                $display("Time = %0t: Teste falhou! Dado enviado: %2h. Dado recebido: %h", $time, i, data_out);
                r_nok = r_nok + 1;
            end
            rx = 1'b1;
            #(2 * CLK_PER_BIT * CLK_PERIOD);
        end

        $display("Dados recebidos de forma correta: %3d/256", r_ok);
		$display("Dados recebidos de forma erronea: %3d/256", r_nok);

        // Finaliza a simulacao
        #(20 * CLK_PER_BIT * CLK_PERIOD);
        $finish;
    end

    // Procedimento para enviar um byte (start, 8 bits de dados e stop bit)
    task send_byte(input [7:0] byte);
        integer j;
        begin
		    @(posedge clk_rx_tb) begin
                rx = 1'b0; // Start bit
                #(CLK_PER_BIT * CLK_PERIOD);
                for (j = 0; j < 8; j = j + 1) begin
                    rx = byte[j];
                    #(CLK_PER_BIT * CLK_PERIOD);
                end
                rx = 1'b1; // Stop bit
                #(CLK_PER_BIT * CLK_PERIOD);
            end
        end
    endtask

    // Procedimento para enviar um byte com erro no stop bit
    task send_byte_with_error(input [7:0] byte);
        integer k;
        begin
			@(posedge clk_rx_tb) begin
                rx = 1'b0; // Start bit
                #(CLK_PER_BIT * CLK_PERIOD);
                for (k = 0; k < 8; k = k + 1) begin
                    rx = byte[k];
                    #(CLK_PER_BIT * CLK_PERIOD);
                end
                rx = 1'b0; // Erro no stop bit (deveria ser 1)
                #(CLK_PER_BIT * CLK_PERIOD);
            end
        end
    endtask

endmodule