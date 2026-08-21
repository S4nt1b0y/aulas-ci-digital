module ALU #(
parameter WIDTH = 8
) (
input [WIDTH-1:0] in1, in2,
input [3:0] op,
input invalid_data,
output reg [2*WIDTH-1:0] out,
output zero,
output error
);
    always@(*) begin
        case (op)
            0: out = in1 + in2;
            1: out = in1-in2;
            2: out = in1 * in2;
            3: if (in2 != 0) out = in1/in2; else out = -1;
            default: out = {2*WIDTH{1'b0}};
        endcase
    end
    assign zero = ~|out;
    assign error = ((op == 3) && (in2 == 0) ? 1'b1 : 
                    (invalid_data ? 1'b1 : 1'b0));
endmodule
