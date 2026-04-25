module moduleName;
    reg[3:0] A;         // Operando A
    reg[3:0] B;         // Operando B
    reg[2:0] seletor;   // Sinal de seleção (3 bits)
    wire[3:0] resultado; // Resultado da operação



    ula ula_i(
        .A(A),
        .B(B),
        .seletor(seletor),
        .resultado(resultado)
    );

    initial begin
        A = 4'b0101;
        B = ~(A);
        seletor = 3'b000;
        #1;
        if(resultado == 4'b0000) begin
            $display("PASSOU teste1");
        end

        A = 4'b0101;
        B = ~(A);
        seletor = 3'b001;
        #1;
        if(resultado == 4'b1111) begin
            $display("PASSOU teste2");
        end

        A = 4'b0000;
        B = ~(A);
        seletor = 3'b010;
        #1;
        if(resultado == 4'b1111) begin
            $display("PASSOU teste3");
        end

        A = 4'b0101;
        B = ~(A);
        seletor = 3'b011;
        #1;
        if(resultado == 4'b1111) begin
            $display("PASSOU teste4");
        end


        A = 4'b1111;
        B = 4'b0001;
        seletor = 3'b100;
        #1;
        if(resultado == 4'b0000) begin
            $display("PASSOU teste5");
        end

        A = 4'b0001;
        B = 4'b1111;
        seletor = 3'b101;
        #1;
        if(resultado == 4'b0010) begin
            $display("PASSOU teste5");
        end

        A = 4'b0001;
        B = 4'b1111;
        seletor = 3'b101;
        #1;
        if(resultado == 4'b0010) begin
            $display("PASSOU teste5");
        end

        A = 4'b0011;
        B = 4'b0011;
        seletor = 3'b110;
        #1;
        if(resultado == 4'b1000) begin
            $display("PASSOU teste5");
        end

        A = 4'b0011;
        B = 4'b0001;
        seletor = 3'b111;
        #1;
        if(resultado == 4'b0001) begin
            $display("PASSOU teste5");
        end


        A = 4'b0011;
        B = 4'b1011;
        seletor = 3'b110;
        #1;
        if(resultado == 4'b1000) begin
            $display("PASSOU teste5");
        end

        A = 4'b0011;
        B = 4'b1001;
        seletor = 3'b111;
        #1;
        if(resultado == 4'b0001) begin
            $display("PASSOU teste5");
        end

    end

endmodule
    
    