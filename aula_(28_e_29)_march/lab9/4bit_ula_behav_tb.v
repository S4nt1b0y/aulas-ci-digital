module moduleName;
    reg[3:0] A;         // Operando A
    reg[3:0] B;         // Operando B
    reg[3:0] seletor;   // Sinal de seleção (3 bits)
    wire[3:0] resultado; // Resultado da operação
    wire C, V, Z, N;      // Flags


    ula ula_i(
        .A(A),
        .B(B),
        .seletor(seletor),
        .resultado(resultado),
        .C(C),
        .V(V),
        .Z(Z),
        .N(N),
        .propagated_out(),
        .generated_out()
    );

    initial begin
        A = 4'b0101;
        B = ~(A);
        seletor = 4'b0000;
        #1;
        if(resultado == 4'b0000) begin
            $display("PASSOU teste1");
        end

        A = 4'b0101;
        B = ~(A);
        seletor = 4'b0001;
        #1;
        if(resultado == 4'b1111) begin
            $display("PASSOU teste2");
        end

        A = 4'b0000;
        B = ~(A);
        seletor = 4'b0010;
        #1;
        if(resultado == 4'b1111) begin
            $display("PASSOU teste3");
        end

        A = 4'b0101;
        B = ~(A);
        seletor = 4'b0011;
        #1;
        if(resultado == 4'b1111) begin
            $display("PASSOU teste4");
        end


        A = 4'b1111;
        B = 4'b0001;
        seletor = 4'b0100;
        #1;
        if(resultado == 4'b0000) begin
            $display("PASSOU teste5");
        end

        A = 4'b0001;
        B = 4'b1111;
        seletor = 4'b0101;
        #1;
        if(resultado == 4'b0010) begin
            $display("PASSOU teste6");
        end

        A = 4'b0001;
        B = 4'b1111;
        seletor = 4'b0101;
        #1;
        if(resultado == 4'b0010) begin
            $display("PASSOU teste7");
        end

        A = 4'b0011;
        B = 4'b0011;
        seletor = 4'b0110;
        #1;
        if(resultado == 4'b1000) begin
            $display("PASSOU teste8");
        end

        A = 4'b0011;
        B = 4'b0001;
        seletor = 4'b0111;
        #1;
        if(resultado == 4'b0001) begin
            $display("PASSOU teste9");
        end


        A = 4'b0011;
        B = 4'b1011;
        seletor = 4'b0110;
        #1;
        if(resultado == 4'b1000) begin
            $display("PASSOU teste10");
        end

        A = 4'b0011;
        B = 4'b1001;
        seletor = 4'b0111;
        #1;
        if(resultado == 4'b0001) begin
            $display("PASSOU teste11");
        end

        A = 4'b0010; B = 4'b0011; seletor = 4'b0100; #1;
        if(resultado == 4'b0101) $display("PASSOU teste Soma sem overflow");
        $display("Flags: C=%b V=%b Z=%b N=%b", C, V, Z, N);

        A = 4'b0111; B = 4'b0001; seletor = 4'b0100; #1;
        if(resultado == 4'b1000 && C == 1) $display("PASSOU teste Soma com carry");
        $display("Flags: C=%b V=%b Z=%b N=%b", C, V, Z, N);

        A = 4'b0101; B = 4'b0011; seletor = 4'b0101; #1;
        if(resultado == 4'b0010) $display("PASSOU teste Subtração normal");
        $display("Flags: C=%b V=%b Z=%b N=%b", C, V, Z, N);
        // =============================
        // Teste 8: Subtração com underflow (V=1)
        // =============================
        A = 4'b1000; B = 4'b0001; seletor = 4'b0101; #1;
        if(resultado == 4'b0111 && V == 1) $display("PASSOU teste Subtração com underflow");
        $display("Flags: C=%b V=%b Z=%b N=%b", C, V, Z, N);

        // =============================
        // Teste 9: Resultado zero (Z=1)
        // =============================
        A = 4'b0101; B = 4'b0101; seletor = 4'b0100; #1;
        if(resultado == 4'b1010) $display("RESULTADO NÃO ZERO"); // exemplo normal


        A = 4'b0110; B = 4'b1010; seletor = 4'b0100; #1;
        if(Z == 0) $display("Z correto"); 

        A = 4'b0000; B = 4'b0000; seletor = 4'b0000; #1;
        if(Z == 1) $display("PASSOU teste Z=1");
        $display("Flags: C=%b V=%b Z=%b N=%b", C, V, Z, N);

        A = 4'b1000; B = 4'b0000; seletor = 4'b0010; #1;
        if(N == 1) $display("PASSOU teste N=1");
        $display("Flags: C=%b V=%b Z=%b N=%b", C, V, Z, N);

        // =============================
        // Teste 11: Shift Left
        // =============================
        A = 4'b0011; B = 4'b0010; seletor = 4'b0110; #1;
        if(resultado == 4'b1100) $display("PASSOU teste LSL");
        $display("Flags: C=%b V=%b Z=%b N=%b", C, V, Z, N);

        // =============================
        // Teste 12: Shift Right
        // =============================
        A = 4'b1100; B = 4'b0010; seletor = 4'b0111; #1;
        if(resultado == 4'b0011) $display("PASSOU teste LSR");
        $display("Flags: C=%b V=%b Z=%b N=%b", C, V, Z, N);
    
        // =============================
        // Teste 13: XOR
        // =============================
        A = 4'b1010; B = 4'b1010; seletor = 4'b1000; #1;
        if(resultado == 4'b0000) $display("PASSOU teste XOR");
        $display("Flags: C=%b V=%b Z=%b N=%b", C, V, Z, N);

        // =============================
        // Teste 14: NOR
        // =============================
        A = 4'b1010; B = 4'b0101; seletor = 4'b1001; #1;
        if(resultado == 4'b0000) $display("PASSOU teste NOR");
        $display("Flags: C=%b V=%b Z=%b N=%b", C, V, Z, N);
    
    
    
    end

endmodule
    
    