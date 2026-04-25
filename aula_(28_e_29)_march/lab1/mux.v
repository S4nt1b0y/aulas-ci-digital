module mux
#(
    parameter WIDTH = 5
)(
    input wire[WIDTH-1:0]     in0,
    input wire[WIDTH-1:0]     in1,
    input wire[WIDTH-1:0]     in2,
    input wire[WIDTH-1:0]     in3,
    input wire[1:0]           sel,
    output reg[WIDTH-1:0]    mux_out
);

always @(*) begin
    case (sel)
        2'b11: mux_out = in3;
        2'b10: mux_out = in2;
        2'b01: mux_out = in1;
        2'b00: mux_out = in0;
    endcase
end

endmodule