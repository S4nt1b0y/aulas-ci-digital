module Seno_Decoder (
    input wire [7:0] phase,
    output reg [3:0] lut_index
 );

always @(*)begin
    case (phase)
        7'd00 : lut_index = 4'd0;
        7'd10 : lut_index = 4'd1;
        7'd20 : lut_index = 4'd2;
        7'd30 : lut_index = 4'd3;
        7'd40 : lut_index = 4'd4;
        7'd50 : lut_index = 4'd5;
        7'd60 : lut_index = 4'd6;
        7'd70 : lut_index = 4'd7;
        7'd80 : lut_index = 4'd8;
        7'd90 : lut_index = 4'd9;
        default: lut_index = 4'd0;
    endcase
end

endmodule