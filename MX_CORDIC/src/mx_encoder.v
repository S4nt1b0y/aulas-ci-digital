`timescale 1ns/1ps

module mx_encoder (
    input  wire signed [15:0] in0_int,
    input  wire signed [15:0] in1_int,
    input  wire signed [15:0] in2_int,
    input  wire signed [15:0] in3_int,
    output reg         [31:0] elems_out, // 4 elementos de 8 bits (E5M2)
    output reg         [7:0]  scale_out, // Escala compartilhada (E8M0)
    output reg                overflow
);

    // A magnitude precisa de 16 bits sem sinal para representar abs(-32768).
    function automatic [15:0] abs_q1_15;
        input signed [15:0] value;
        begin
            abs_q1_15 = value[15] ? (~value + 16'd1) : value;
        end
    endfunction

    function automatic integer msb_index32;
        input [31:0] value;
        integer i;
        begin
            msb_index32 = -1;
            for (i = 31; i >= 0; i = i - 1) begin
                if (value[i] && msb_index32 < 0)
                    msb_index32 = i;
            end
        end
    endfunction

    // Codifica a magnitude ja dividida pela escala compartilhada. A mantissa
    // usa truncamento e bits ausentes a direita do LSB sao tratados como zero.
    function automatic [7:0] encode_e5m2;
        input        sign;
        input [31:0] abs_value;
        integer msb;
        integer exp_value;
        reg [4:0] exp;
        reg [1:0] mant;
        begin
            if (abs_value == 0) begin
                encode_e5m2 = {sign, 7'd0};
            end else begin
                msb = msb_index32(abs_value);
                exp_value = msb + 15;

                if (exp_value < 1) begin
                    exp = 5'd0;
                    mant = 2'd0;
                end else if (exp_value > 30) begin
                    exp = 5'd30;
                    mant = 2'b11;
                end else begin
                    exp = exp_value[4:0];
                    if (msb >= 2)
                        mant = (abs_value >> (msb - 2)) & 2'b11;
                    else
                        mant = (abs_value << (2 - msb)) & 2'b11;
                end

                encode_e5m2 = {sign, exp, mant};
            end
        end
    endfunction

    reg [15:0] a0, a1, a2, a3;
    reg [15:0] maxa;
    reg [31:0] scaled_a0, scaled_a1, scaled_a2, scaled_a3;
    integer max_msb;
    integer scale_exp;
    integer shift_amt;

    always @(*) begin
        overflow = 1'b0;
        elems_out = 32'd0;
        scale_out = 8'd127;

        a0 = abs_q1_15(in0_int);
        a1 = abs_q1_15(in1_int);
        a2 = abs_q1_15(in2_int);
        a3 = abs_q1_15(in3_int);

        maxa = a0;
        if (a1 > maxa) maxa = a1;
        if (a2 > maxa) maxa = a2;
        if (a3 > maxa) maxa = a3;

        scaled_a0 = 32'd0;
        scaled_a1 = 32'd0;
        scaled_a2 = 32'd0;
        scaled_a3 = 32'd0;

        if (maxa != 0) begin
            max_msb = msb_index32({16'd0, maxa});

            // O expoente real de um raw Q1.15 e max_msb - 15. O maior
            // expoente normal E5M2 e 15, portanto e_scale = max_msb - 30.
            scale_exp = max_msb - 30;
            if (scale_exp > 127) begin
                scale_exp = 127;
                overflow = 1'b1;
            end else if (scale_exp < -127) begin
                scale_exp = -127;
            end

            scale_out = scale_exp + 127;
            if (scale_out == 8'hff) begin
                scale_out = 8'hfe;
                overflow = 1'b1;
            end

            // Traz o MSB da maior magnitude para a posicao 15, equivalente
            // a dividir os valores reais pela escala compartilhada.
            shift_amt = 15 - max_msb;
            scaled_a0 = {16'd0, a0} << shift_amt;
            scaled_a1 = {16'd0, a1} << shift_amt;
            scaled_a2 = {16'd0, a2} << shift_amt;
            scaled_a3 = {16'd0, a3} << shift_amt;

            elems_out[7:0]   = encode_e5m2(in0_int[15], scaled_a0);
            elems_out[15:8]  = encode_e5m2(in1_int[15], scaled_a1);
            elems_out[23:16] = encode_e5m2(in2_int[15], scaled_a2);
            elems_out[31:24] = encode_e5m2(in3_int[15], scaled_a3);
        end
    end
endmodule
