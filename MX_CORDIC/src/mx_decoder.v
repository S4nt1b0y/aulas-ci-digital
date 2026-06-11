module mx_decoder (
    input  wire [31:0] elems_in,
    input  wire [7:0]  scale_in,
    output reg  signed [31:0] phase0_q16,
    output reg  signed [31:0] phase1_q16,
    output reg  signed [31:0] phase2_q16,
    output reg  signed [31:0] phase3_q16,
    output reg               any_nan
);

    function automatic signed [31:0] decode_e5m2_q16;
        input [7:0] fp;
        integer exp_unbias;
        integer frac_q16;
        integer sig_q16;
        reg sign;
        reg [4:0] exp;
        reg [1:0] mant;
        reg signed [63:0] tmp;
        begin
            sign = fp[7];
            exp  = fp[6:2];
            mant = fp[1:0];

            if (exp == 5'b11111) begin
                decode_e5m2_q16 = 32'sh7fffffff;
            end else if (exp == 5'b00000) begin
                if (mant == 2'b00) begin
                    decode_e5m2_q16 = 32'sd0;
                end else begin
                    frac_q16 = ({14'd0, mant} << 14);
                    exp_unbias = -14;
                    if (exp_unbias >= 0) tmp = frac_q16 <<< exp_unbias;
                    else tmp = frac_q16 >>> (-exp_unbias);
                    if (sign) tmp = -tmp;
                    decode_e5m2_q16 = tmp[31:0];
                end
            end else begin
                sig_q16 = (32'sd1 <<< 16) + ({14'd0, mant} <<< 14);
                exp_unbias = $signed({1'b0,exp}) - 15;
                if (exp_unbias >= 0) tmp = sig_q16 <<< exp_unbias;
                else tmp = sig_q16 >>> (-exp_unbias);
                if (sign) tmp = -tmp;
                decode_e5m2_q16 = tmp[31:0];
            end
        end
    endfunction

    function automatic signed [31:0] scale_e8m0_q16;
        input [7:0] s;
        integer e;
        reg signed [63:0] one_q16;
        begin
            if (s == 8'hff) begin
                scale_e8m0_q16 = 32'sh7fffffff;
            end else begin
                one_q16 = 32'sd1 <<< 16;
                e = $signed({1'b0,s}) - 127;
                if (e >= 0) begin
                    if (e > 14) scale_e8m0_q16 = 32'sh7fffffff;
                    else begin
                        one_q16 = (one_q16 <<< e);
                        scale_e8m0_q16 = one_q16;
                    end
                end else begin
                    if (e < -30) scale_e8m0_q16 = 32'sd0;
                    else begin
                        one_q16 = (one_q16 >>> (-e));
                        scale_e8m0_q16 = one_q16;
                    end
                end
            end
        end
    endfunction

    function automatic signed [31:0] mul_q16;
        input signed [31:0] a;
        input signed [31:0] b;
        reg signed [63:0] p;
        begin
            p = a * b;
            mul_q16 = p >>> 16;
        end
    endfunction

    wire signed [31:0] p0 = decode_e5m2_q16(elems_in[7:0]);
    wire signed [31:0] p1 = decode_e5m2_q16(elems_in[15:8]);
    wire signed [31:0] p2 = decode_e5m2_q16(elems_in[23:16]);
    wire signed [31:0] p3 = decode_e5m2_q16(elems_in[31:24]);
    wire signed [31:0] xq = scale_e8m0_q16(scale_in);

    always @(*) begin
        any_nan   = 1'b0;
        phase0_q16 = mul_q16(p0, xq);
        phase1_q16 = mul_q16(p1, xq);
        phase2_q16 = mul_q16(p2, xq);
        phase3_q16 = mul_q16(p3, xq);

        if (scale_in == 8'hff || p0 == 32'sh7fffffff || p1 == 32'sh7fffffff || p2 == 32'sh7fffffff || p3 == 32'sh7fffffff) begin
            any_nan    = 1'b1;
            phase0_q16 = 32'sd0;
            phase1_q16 = 32'sd0;
            phase2_q16 = 32'sd0;
            phase3_q16 = 32'sd0;
        end
    end
endmodule
