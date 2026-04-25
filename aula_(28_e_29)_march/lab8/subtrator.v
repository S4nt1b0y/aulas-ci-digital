module subtrator
#(
    parameter WIDTH = 4
)
(
    input wire[WIDTH-1:0] operandA,
    input wire[WIDTH-1:0] operandB,
    input wire carry_in,
    output wire[WIDTH-1:0] result,
    output wire  carry_out,
    output wire propagated,
    output wire generated
);

wire [WIDTH-1:0] changed_B;
wire changed_carry_in;
wire carry_out_somador;

assign changed_B        = ~(operandB);
assign changed_carry_in = ~(carry_in);

somador_cla 
        #(.WIDTH(WIDTH))
        somador_cla_i(
        .operandA(operandA),
        .operandB(changed_B),
        .carry_in(changed_carry_in),
        .result(result),
        .carry_out(carry_out_somador),
        .propagated(propagated),
        .generated(generated)
    );

assign carry_out = !(carry_out_somador);

endmodule