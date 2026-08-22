`timescale 1ns/100ps
module aFifo_TB
   #(parameter   DATA_WIDTH    = 8,
                 ADDRESS_WIDTH = 4,
                 FIFO_DEPTH    = (1 << ADDRESS_WIDTH));
					  
	  wire[DATA_WIDTH-1:0]         Data_out;
     wire                         Empty_out;
     reg                          ReadEn_in;
     reg                          RClk;        
     //Writing port.	 
     reg  [DATA_WIDTH-1:0]        Data_in;  
     wire                         Full_out;
     reg                          WriteEn_in;
     reg                          WClk;
	 
     reg                          Clear_in;
	 reg 						  Read_more_fast;

	integer k;
					  
	// Disponibilizando o DUT(Device-Under-Test)
	aFifo DUT (
		.Data_out(Data_out),
		.Empty_out(Empty_out),
		.ReadEn_in(ReadEn_in),
		.RClk(RClk),
		.Data_in(Data_in),
		.Full_out(Full_out),
		.WriteEn_in(WriteEn_in),
		.WClk(WClk),
		.Clear_in(Clear_in)
		);

	// Aplicando os estimulos
	always 
		if(Read_more_fast) begin
			#23 RClk = ~RClk;
		end else begin 
			#29 RClk = ~RClk;
		end
		
	always
		if(Read_more_fast) begin
			#29 WClk = ~WClk;
		end else begin 
			#23 WClk = ~WClk;
		end
	
	initial begin
		WClk       <= 0;
		RClk       <= 0;
		ReadEn_in  <= 0;
		WriteEn_in <= 0;
		Clear_in   <= 0;
		Data_in    <= 0;
		Read_more_fast <= 1;

		// --------------------------------------------------
		// RESET
		// --------------------------------------------------

		#20;
		Clear_in <= 1;

		#40;
		Clear_in <= 0;

		// Espera alguns ciclos para a FIFO estabilizar
		#40;

		// --------------------------------------------------
		// PREENCHER FIFO ATÉ FULL
		// --------------------------------------------------

		WriteEn_in <= 1;

		wait (Full_out == 1);

		// Full_out foi detectado
		WriteEn_in <= 0;

		$display("t=%0t -> FIFO FULL", $time);

		// --------------------------------------------------
		// ESVAZIAR FIFO ATÉ EMPTY
		// --------------------------------------------------

		ReadEn_in <= 1;

		wait (Empty_out == 1);

		// Empty_out foi detectado
		ReadEn_in <= 0;

		$display("t=%0t -> FIFO EMPTY", $time);

		#100;

		test_concurrent;
		Read_more_fast <= 1;
		#5;
		test_concurrent;
		$stop;
	end
	
	initial begin
		Clear_in <= 0;
		#20 Clear_in <= 1;
		#40 Clear_in <= 0;
	end
	
	initial begin
		#65 Data_in <= 0;
		for (k=0; k < 32; k = k + 1)
			#58 Data_in <= k;
	end

	task automatic test_concurrent;
		integer write_count;
		integer read_count;

		begin

			write_count = 0;
			read_count  = 0;

			WriteEn_in = 0;
			ReadEn_in  = 0;

			while ((write_count < 200) || (read_count < 200)) begin

				// =================================================
				// Espera uma borda de clock
				// =================================================

				@(posedge WClk or posedge RClk);


				// =================================================
				// ESCRITA
				// =================================================

				if (WClk && write_count < 200) begin

					if (!Full_out) begin

						Data_in = write_count;
						WriteEn_in = 1;

						write_count = write_count + 1;

						$display(
							"[WRITE] t=%0t Data=%0d Count=%0d",
							$time,
							Data_in,
							write_count
						);

					end

				end


				// =================================================
				// LEITURA
				// =================================================

				if (RClk && read_count < 200) begin

					if (!Empty_out) begin

						ReadEn_in = 1;

						read_count = read_count + 1;

						$display(
							"[READ] t=%0t Data=%0d Count=%0d",
							$time,
							Data_out,
							read_count
						);

					end

				end


				// =================================================
				// Desabilita os enables
				// =================================================

				#1;

				WriteEn_in = 0;
				ReadEn_in  = 0;

			end

			$display("");
			$display("======================================");
			$display(" TESTE CONCORRENTE FINALIZADO");
			$display(" Escritas aceitas = %0d", write_count);
			$display(" Leituras aceitas  = %0d", read_count);
			$display("======================================");

		end
	endtask

	initial 
		#40000	$stop;
		
endmodule

	