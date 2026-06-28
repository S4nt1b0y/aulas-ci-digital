module LUT_Seno (
    input  [5:0]  index0,
    input  [5:0]  index1,
    input  [5:0]  index2,
    input  [5:0]  index3,
    output [32:0] sin_value0,
    output [32:0] sin_value1,
    output [32:0] sin_value2,
    output [32:0] sin_value3
);

reg [32:0] memoria [0:63];

initial begin
    memoria[0]  = 32'd0;
    memoria[1]  = 32'd817;
    memoria[2]  = 32'd1634;
    memoria[3]  = 32'd2450;
    memoria[4]  = 32'd3265;
    memoria[5]  = 32'd4079;
    memoria[6]  = 32'd4890;
    memoria[7]  = 32'd5699;
    memoria[8]  = 32'd6504;
    memoria[9]  = 32'd7306;
    memoria[10] = 32'd8103;
    memoria[11] = 32'd8896;
    memoria[12] = 32'd9683;
    memoria[13] = 32'd10464;
    memoria[14] = 32'd11239;
    memoria[15] = 32'd12006;
    memoria[16] = 32'd12766;
    memoria[17] = 32'd13518;
    memoria[18] = 32'd14261;
    memoria[19] = 32'd14995;
    memoria[20] = 32'd15719;
    memoria[21] = 32'd16433;
    memoria[22] = 32'd17136;
    memoria[23] = 32'd17827;
    memoria[24] = 32'd18507;
    memoria[25] = 32'd19174;
    memoria[26] = 32'd19829;
    memoria[27] = 32'd20470;
    memoria[28] = 32'd21097;
    memoria[29] = 32'd21710;
    memoria[30] = 32'd22308;
    memoria[31] = 32'd22890;
    memoria[32] = 32'd23457;
    memoria[33] = 32'd24007;
    memoria[34] = 32'd24540;
    memoria[35] = 32'd25056;
    memoria[36] = 32'd25555;
    memoria[37] = 32'd26035;
    memoria[38] = 32'd26497;
    memoria[39] = 32'd26939;
    memoria[40] = 32'd27363;
    memoria[41] = 32'd27766;
    memoria[42] = 32'd28150;
    memoria[43] = 32'd28513;
    memoria[44] = 32'd28855;
    memoria[45] = 32'd29177;
    memoria[46] = 32'd29477;
    memoria[47] = 32'd29756;
    memoria[48] = 32'd30013;
    memoria[49] = 32'd30247;
    memoria[50] = 32'd30460;
    memoria[51] = 32'd30650;
    memoria[52] = 32'd30817;
    memoria[53] = 32'd30962;
    memoria[54] = 32'd31084;
    memoria[55] = 32'd31182;
    memoria[56] = 32'd31258;
    memoria[57] = 32'd31310;
    memoria[58] = 32'd31339;
    memoria[59] = 32'd31345;
    memoria[60] = 32'd31327;
    memoria[61] = 32'd31286;
    memoria[62] = 32'd31222;
    memoria[63] = 32'd32767;
end

assign sin_value0 = memoria[index0];
assign sin_value1 = memoria[index1];
assign sin_value2 = memoria[index2];
assign sin_value3 = memoria[index3];

endmodule
