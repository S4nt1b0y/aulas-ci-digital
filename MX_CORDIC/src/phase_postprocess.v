`timescale 1ns/1ps

module phase_postprocess(
    input  wire signed [31:0] lut0,
    input  wire signed [31:0] lut1,
    input  wire signed [31:0] lut2,
    input  wire signed [31:0] lut3,

    input  wire negate0,
    input  wire negate1,
    input  wire negate2,
    input  wire negate3,

    output reg signed [31:0] out0,
    output reg signed [31:0] out1,
    output reg signed [31:0] out2,
    output reg signed [31:0] out3
);

always @(*) begin

    out0 = negate0 ? -$signed(lut0) : $signed(lut0);
    out1 = negate1 ? -$signed(lut1) : $signed(lut1);
    out2 = negate2 ? -$signed(lut2) : $signed(lut2);
    out3 = negate3 ? -$signed(lut3) : $signed(lut3);

end

endmodule
