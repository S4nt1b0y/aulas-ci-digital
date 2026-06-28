module LUT (
    input  [5:0]  index,
    output [15:0] sin_q15
);

reg [15:0] memoria [0:63];

initial begin
    memoria[0]  = 16'd0;
    memoria[1]  = 16'd817;
    memoria[2]  = 16'd1634;
    memoria[3]  = 16'd2450;
    memoria[4]  = 16'd3265;
    memoria[5]  = 16'd4079;
    memoria[6]  = 16'd4890;
    memoria[7]  = 16'd5699;
    memoria[8]  = 16'd6504;
    memoria[9]  = 16'd7306;
    memoria[10] = 16'd8103;
    memoria[11] = 16'd8896;
    memoria[12] = 16'd9683;
    memoria[13] = 16'd10464;
    memoria[14] = 16'd11239;
    memoria[15] = 16'd12006;
    memoria[16] = 16'd12766;
    memoria[17] = 16'd13518;
    memoria[18] = 16'd14261;
    memoria[19] = 16'd14995;
    memoria[20] = 16'd15719;
    memoria[21] = 16'd16433;
    memoria[22] = 16'd17136;
    memoria[23] = 16'd17827;
    memoria[24] = 16'd18507;
    memoria[25] = 16'd19174;
    memoria[26] = 16'd19829;
    memoria[27] = 16'd20470;
    memoria[28] = 16'd21097;
    memoria[29] = 16'd21710;
    memoria[30] = 16'd22308;
    memoria[31] = 16'd22890;
    memoria[32] = 16'd23457;
    memoria[33] = 16'd24007;
    memoria[34] = 16'd24540;
    memoria[35] = 16'd25056;
    memoria[36] = 16'd25555;
    memoria[37] = 16'd26035;
    memoria[38] = 16'd26497;
    memoria[39] = 16'd26939;
    memoria[40] = 16'd27363;
    memoria[41] = 16'd27766;
    memoria[42] = 16'd28150;
    memoria[43] = 16'd28513;
    memoria[44] = 16'd28855;
    memoria[45] = 16'd29177;
    memoria[46] = 16'd29477;
    memoria[47] = 16'd29756;
    memoria[48] = 16'd30013;
    memoria[49] = 16'd30247;
    memoria[50] = 16'd30460;
    memoria[51] = 16'd30650;
    memoria[52] = 16'd30817;
    memoria[53] = 16'd30962;
    memoria[54] = 16'd31084;
    memoria[55] = 16'd31182;
    memoria[56] = 16'd31258;
    memoria[57] = 16'd31310;
    memoria[58] = 16'd31339;
    memoria[59] = 16'd31345;
    memoria[60] = 16'd31327;
    memoria[61] = 16'd31286;
    memoria[62] = 16'd31222;
    memoria[63] = 16'd32767;
end

assign sin_q15 = memoria[index];

endmodule
