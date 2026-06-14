module mx_encoder (
    input  wire signed [31:0] in0_q16,
    input  wire signed [31:0] in1_q16,
    input  wire signed [31:0] in2_q16,
    input  wire signed [31:0] in3_q16,
    output reg  [31:0] elems_out,
    output reg  [7:0]  scale_out,
    output reg         overflow
);

    function automatic signed [31:0] abs32;
        input signed [31:0] v;
        begin
            abs32 = (v < 0) ? -v : v;
        end
    endfunction

    function automatic integer msb_index32;
        input [31:0] v;
        integer i;
        begin
            msb_index32 = -1;
            for (i = 31; i >= 0; i = i - 1) begin
                if (v[i] && msb_index32 < 0)
                    msb_index32 = i;
            end
        end
    endfunction

    function automatic signed [63:0] scale_to_m_q16;
        input signed [31:0] a;
        input signed [7:0]  e;
        reg signed [63:0] t;
        begin
            t = a;
            if (e >= 0)
                scale_to_m_q16 = t >>> e;
            else
                scale_to_m_q16 = t <<< (-e);
        end
    endfunction

    function automatic [7:0] enc_e5m2;
        input signed [31:0] val_q16;
        input signed [7:0]  e;
        reg sign;
        reg signed [31:0] a;
        reg signed [63:0] m_q16;
        reg [1:0] mant;
        reg [4:0] exp;
        begin
            sign = val_q16[31];
            a = sign ? -val_q16 : val_q16;
            if (a == 0) begin
                enc_e5m2 = {sign, 7'd0};
            end else begin
                m_q16 = scale_to_m_q16(a, e);
                if (m_q16 < (1 <<< 16)) m_q16 = (1 <<< 16); //mantissa < 1.0 → força para 1.0
                if (m_q16 > (7 <<< 14)) m_q16 = (7 <<< 14); //mantissa > 1.75 → força para 1.75 Como só tem 2bits o intervalo representavel é 1.00,1.25,1.50,1.75

                mant = (m_q16 - (1 <<< 16) + (1 <<< 13)) >>> 14; //Quantização para 2bits, ou fica 00,01,10 ou 11
                
                exp = 5'd15; //Isso aqui parece estar errado

                enc_e5m2 = {sign, exp, mant};
            end
        end
    endfunction

    reg signed [7:0] e;
    integer msb_idx;
    reg signed [31:0] a0, a1, a2, a3;
    reg signed [31:0] maxa;
    reg [7:0] e5_0, e5_1, e5_2, e5_3;

    always @(*) begin
        overflow = 1'b0;
        a0 = abs32(in0_q16);
        a1 = abs32(in1_q16);
        a2 = abs32(in2_q16);
        a3 = abs32(in3_q16);

        maxa = a0;
        if (a1 > maxa) maxa = a1;
        if (a2 > maxa) maxa = a2;
        if (a3 > maxa) maxa = a3;

        if (maxa == 0) begin
            scale_out = 8'd127;
            elems_out = 32'd0;
        end else begin
            msb_idx = msb_index32(maxa[31:0]);
            e = msb_idx - 16;

            if (e > 127) begin //Tratando Overflow
                e = 127;
                overflow = 1'b1;
            end
            if (e < -127)     //Tratando Underflow
                e = -127;

            scale_out = e + 127; //Colocando no formato com bias ocultor
            if (scale_out == 8'hff) begin //Como ff é reservado para inf ou NaN vamos deixar em fe
                scale_out = 8'hfe;
                overflow = 1'b1;
            end

            e5_0 = enc_e5m2(in0_q16, e);
            e5_1 = enc_e5m2(in1_q16, e);
            e5_2 = enc_e5m2(in2_q16, e);
            e5_3 = enc_e5m2(in3_q16, e);
            elems_out = {e5_3, e5_2, e5_1, e5_0};
        end
    end
endmodule
