module alu_12bit_tb;

    localparam NUM_OF_TESTS = 10;
    localparam WIDTH = 12;

    reg [11:0] A, B;
    reg [3:0] seletor;
    reg carry_in;
    reg sub;

    wire [11:0] resultado;
    wire C, V, Z, N;
    wire P, G;

    // Instância da ULA 12 bits
    alu12bit dut (
        .A(A),
        .B(B),
        .seletor(seletor),
        .carry_in(carry_in),
        .resultado(resultado),
        .C(C),
        .V(V),
        .Z(Z),
        .N(N),
        .propagated_out(P),
        .generated_out(G)
    );

     initial begin
        repeat(NUM_OF_TESTS) begin  //Testes de SOMA
            A = $random; 
            B = $random; 
            carry_in = $random;
            seletor = 4'b0100;
            sub = 0;
            #10;

            expect(A, B, carry_in, sub);
        end

        repeat(NUM_OF_TESTS) begin  //Testes de SUB
            A = $random; 
            B = $random; 
            carry_in = $random;
            seletor = 4'b0101;
            sub = 1;
            #10;

            expect(A, B, carry_in, sub);
        end
        
        $finish;
    end

    task expect(
        input [WIDTH-1:0] opA,
        input [WIDTH-1:0] opB,
        input C_in,
        input sub
    );
        reg[WIDTH:0] tempResult;

        begin
            if(sub) begin
                tempResult = opA - opB - C_in;
            end else begin
                 tempResult = opA + opB + C_in;
            end
           

            if((tempResult[WIDTH-1:0] != resultado) || (tempResult[WIDTH] != C)) begin
                $display("TESTE FALHOU");
                 $display("sub? %b", sub);
                $display("operandA = %b | operandB = %b | carry_in= %b | result = %b | expected = %b | carry_out = %b", A, B, carry_in, resultado, tempResult[WIDTH-1:0], C);
            end
            else begin
                $display("TESTE PASSOU");
            end
        end
    endtask

endmodule