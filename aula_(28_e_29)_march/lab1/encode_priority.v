module encode_priority
(
    input  wire         in0,
    input  wire         in1,
    input  wire         in2,
    input  wire         in3,
    output reg[1:0]    sel
);

always @(*) begin
    if (in3) begin
        sel = 11;
    end else if (in2) begin
        sel = 10;
    end else if (in1) begin
        sel = 01;
    end else begin
        sel = 00;
    end
end

endmodule