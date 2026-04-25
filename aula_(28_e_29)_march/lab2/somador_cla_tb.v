module somador_cla_tb;
    localparam WIDTH = 8;
    localparam NUM_OF_TESTS = 10;

    reg[WIDTH-1:0] operandA;
    reg[WIDTH-1:0] operandB;
    reg carry_in;

    wire[WIDTH-1:0] result;
    wire carry_out;

    somador_cla 
        #(.WIDTH(WIDTH))
        somador_cla_i(
        .operandA(operandA),
        .operandB(operandB),
        .carry_in(carry_in),
        .result(result),
        .carry_out(carry_out)
    );

    initial begin
        repeat(NUM_OF_TESTS) begin 
            operandA = $random; 
            operandB = $random; 
            carry_in = $random;
            #10;

            expect(operandA, operandB, carry_in);
        end
        

        $finish;
    end

    task expect(
        input [WIDTH-1:0] opA,
        input [WIDTH-1:0] opB,
        input C_in
    );
        reg[WIDTH:0] tempResult;

        begin
            tempResult = opA + opB + C_in;

            if((tempResult[WIDTH-1:0] != result) || (tempResult[WIDTH] != carry_out)) begin
                $display("TESTE FALHOU");
                $display("operandA = %b | operandB = %b | carry_in= %b | result = %b | carry_out = %b", operandA, operandB, carry_in,result, carry_out);
            end
            else begin
                $display("TESTE PASSOU");
            end
        end
    endtask

endmodule