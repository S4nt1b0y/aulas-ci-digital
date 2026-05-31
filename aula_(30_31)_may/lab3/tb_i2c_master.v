`timescale 1ns/1ps

module tb_i2c_master;

    reg clk;
    reg reset;
    reg start;
    reg [7:0] data_in;
	wire [7:0] data_slave;
	reg ack_master;
    tri1 scl;
    tri1 sda; // Linha tri-state
    wire done;
    reg rw;
    reg [6:0] slave_addr;
	 
    // Variaveis internas para capturar os dados recebidos e o endereco
    reg [7:0] received_data;   // Registrador para armazenar os dados recebidos
    reg [3:0] data_bit_counter; // Contador para os bits dos dados

    // Variavel para simular o escravo
    reg sda_slave;
	 
	reg [7:0] dado_escravo;
	 
	reg add_data; // determinar se o dado e endereco (0) ou nao (1)
	 
	integer i;
	integer negedge_detected;

    // Controle tri-state para a linha SDA
    assign sda = (sda_slave === 1'bz) ? 1'bz : sda_slave; 
	 
    i2c_master uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .data_in(data_in),
		.data_slave(data_slave),
		.ack_master(ack_master),
        .scl(scl),
        .sda(sda),
        .done(done),
		.rw(rw),
		.slave_addr(slave_addr)
    );

    initial begin
    // Inicializa os sinais
	received_data=0;   
    data_bit_counter=0; 
	sda_slave = 1'bz;
	add_data = 0;
    clk = 0;
    reset = 1;
    start = 0;
	rw = 0; // modo escrita: mestre envia dado ao escravo
	i = 7;
    data_in = 8'hA5; // dado a ser enviado
	dado_escravo = 8'hBC; // dado que o escravo envia
	slave_addr = 7'b1010101; // endereco escravo 55h

    // Libera o reset apos algumas ciclos de clock
    #10 reset = 0;
        
    // Inicia a transferencia de dados
    #20 start = 1;
        
    #100 start = 0;
        
	// Espera a transferencia completar - checar ack
	wait(uut.state == 3);
		  
	// Simula o escravo - envio de ack
	sda_slave = 0;
	
	wait(uut.state == 2) sda_slave = 1'bz; // coloca sda em alta impedancia para o mestre enviar dado
		  
	// Espera a transferencia completar - checar ack
	wait(uut.state == 3);
		  
	//Simula o escravo - envio de ack
	sda_slave = 0;
	 
	wait(uut.state == 2) sda_slave = 1'bz; // coloca sda em alta impedancia para o mestre enviar dado
	
	// Espera a transferencia completar - checar ack
	wait(uut.state == 3);
	 
	//Simula o escravo - envio de nack
	sda_slave = 1;

	wait(uut.state == 6) sda_slave = 1'bz; // encerra a simulacao
	
	// Finaliza a simulacao com rw = 0
    #1000 
	 
	// Inicia a transferencia de dados
	 
	rw = 1; // modo leitura: escravo envia dados ao mestre
    #20 start = 1;
	 
	#100 start = 0;
               
	// Espera a transferencia completar - checar ack
	wait(uut.state == 3);
	 
	// Simula o escravo  - envio ack
	sda_slave = 0;
	 
	wait(uut.state == 4); // espera escravo enviar dados
	 
	// Simula o escravo 
	negedge_detected = 0; // Inicializar o sinal
	 
	for (i = 7; i >= 0; i = i - 1) begin
      sda_slave = dado_escravo[i];
				
      // Aguardar uma das condicoes: borda de descida ou estado 5
	  wait (uut.state == 5 || negedge_detected);
		  
	  // Resetar o sinal apos deteccao
      negedge_detected = 0;

    end
	 
	ack_master = 1; // mestre enviara nack para finalizar simulacao
	 
	wait(uut.state == 4) sda_slave = 1'bz;
	 	 
	#1000 $stop;
    end

	// Detectar a borda de descida de SCL
    always @(negedge scl) begin
        negedge_detected = 1;
    end
	 
    // Geracao de clock
    always #5 clk = ~clk;

    // Armazenamento dos dados recebidos a cada borda de subida do SCL
    always @(posedge scl) begin
		if ((uut.state == 0) || (uut.state == 1)) begin
		    add_data <= 0;
			data_bit_counter <= 0;
			received_data <= 0;
		end else if ((uut.state == 2) || (uut.state == 4)) begin
		      if (data_bit_counter < 8) begin
                received_data[7 - data_bit_counter] <= sda; // Armazena o bit dos dados recebidos
                data_bit_counter <= data_bit_counter + 1; // Incrementa o contador de bits dos dados
        	end 
		end else if ((uut.state == 3) || (uut.state == 5)) begin
            // Quando todos os 8 bits dos dados forem recebidos, faz a comparacao
			if (add_data == 0) begin
			   	$display("Endereco enviado: %2h. Modo RW enviado: %1b ", received_data[7:1], received_data[0]);
  			    $display("Endereco esperado: %2h. Modo RW esperado: %1b ", slave_addr, rw);
				$display("------");
				add_data <= 1;
			end else begin
			    if (rw == 0) begin
                   	$display("Dado enviado: %2h", received_data);
				    $display("Dado esperado: %2h", data_in);
					$display("------");
				end else begin
                   	$display("Dado recebido: %2h", received_data);
				    $display("Dado esperado: %2h", dado_escravo);
					$display("------");
				end
			end
    		data_bit_counter <= 0; // Reseta o contador de bits dos dados
		end
	end

endmodule