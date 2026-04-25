module somador_cla
#(
    parameter WIDTH = 4
)
(
    input wire[WIDTH-1:0] operandA,
    input wire[WIDTH-1:0] operandB,
    input wire carry_in,
    output wire[WIDTH-1:0] result,
    output wire  carry_out
);

wire [WIDTH-1:0] P; //Propagação
wire [WIDTH-1:0] G; //Geração
wire [WIDTH:0] C;   //Cadeia de Carries internos

assign P = operandA ^ operandB;
assign G = operandA & operandB;

assign C[0] = carry_in;

genvar i, j;

generate
    for(i = 1; i <= WIDTH; i = i+1) begin: carry_logic
        wire [i:0] carry_item;

        assign carry_item[0] = G[i-1];

        for (j = 1; j <= i; j = j+1) begin
            if(j<i) begin
                assign carry_item[j] = (&P[i-1:i-j]) & G[i-j-1];
            end else begin
                assign carry_item[j] = (&P[i-1:0]) & C[0];
            end
        end

        assign C[i] = |carry_item;
    end
endgenerate

assign carry_out = C[WIDTH];
assign result = P ^ C[WIDTH-1:0];

endmodule