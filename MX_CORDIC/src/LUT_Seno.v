`timescale 1ns/1ps

module LUT_Seno (
    input  [5:0]  index0,
    input  [5:0]  index1,
    input  [5:0]  index2,
    input  [5:0]  index3,
    output [31:0] sin_value0,
    output [31:0] sin_value1,
    output [31:0] sin_value2,
    output [31:0] sin_value3
);

reg [31:0] memoria [0:63];

initial begin
    memoria[0]  = 32'd0;
    memoria[1]  = 32'd817;
    memoria[2]  = 32'd1633;
    memoria[3]  = 32'd2449;
    memoria[4]  = 32'd3263;
    memoria[5]  = 32'd4074;
    memoria[6]  = 32'd4884;
    memoria[7]  = 32'd5690;
    memoria[8]  = 32'd6493;
    memoria[9]  = 32'd7292;
    memoria[10] = 32'd8086;
    memoria[11] = 32'd8875;
    memoria[12] = 32'd9659;
    memoria[13] = 32'd10436;
    memoria[14] = 32'd11207;
    memoria[15] = 32'd11971;
    memoria[16] = 32'd12728;
    memoria[17] = 32'd13477;
    memoria[18] = 32'd14218;
    memoria[19] = 32'd14949;
    memoria[20] = 32'd15671;
    memoria[21] = 32'd16384;
    memoria[22] = 32'd17086;
    memoria[23] = 32'd17778;
    memoria[24] = 32'd18459;
    memoria[25] = 32'd19128;
    memoria[26] = 32'd19785;
    memoria[27] = 32'd20431;
    memoria[28] = 32'd21063;
    memoria[29] = 32'd21682;
    memoria[30] = 32'd22288;
    memoria[31] = 32'd22880;
    memoria[32] = 32'd23458;
    memoria[33] = 32'd24021;
    memoria[34] = 32'd24569;
    memoria[35] = 32'd25102;
    memoria[36] = 32'd25619;
    memoria[37] = 32'd26120;
    memoria[38] = 32'd26606;
    memoria[39] = 32'd27074;
    memoria[40] = 32'd27526;
    memoria[41] = 32'd27961;
    memoria[42] = 32'd28378;
    memoria[43] = 32'd28778;
    memoria[44] = 32'd29159;
    memoria[45] = 32'd29523;
    memoria[46] = 32'd29868;
    memoria[47] = 32'd30195;
    memoria[48] = 32'd30503;
    memoria[49] = 32'd30792;
    memoria[50] = 32'd31062;
    memoria[51] = 32'd31312;
    memoria[52] = 32'd31543;
    memoria[53] = 32'd31755;
    memoria[54] = 32'd31946;
    memoria[55] = 32'd32118;
    memoria[56] = 32'd32270;
    memoria[57] = 32'd32402;
    memoria[58] = 32'd32514;
    memoria[59] = 32'd32605;
    memoria[60] = 32'd32676;
    memoria[61] = 32'd32727;
    memoria[62] = 32'd32758;
    memoria[63] = 32'd32767;
end

assign sin_value0 = memoria[index0];
assign sin_value1 = memoria[index1];
assign sin_value2 = memoria[index2];
assign sin_value3 = memoria[index3];

endmodule
