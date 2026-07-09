`timescale 1ns/1ps

module mx_sin (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [31:0] elems_in,
    input  wire [7:0]  scale_in,
    output reg  [31:0] elems_out,
    output reg  [7:0]  scale_out,
    output reg         any_nan,
    output reg         overflow,
    output reg         busy,
    output reg         done
);
    wire signed [31:0] phase0_dec;
    wire signed [31:0] phase1_dec;
    wire signed [31:0] phase2_dec;
    wire signed [31:0] phase3_dec;
    wire               any_nan_dec;

    reg signed [31:0] phase0_s1;
    reg signed [31:0] phase1_s1;
    reg signed [31:0] phase2_s1;
    reg signed [31:0] phase3_s1;
    reg               any_nan_s1;

    wire signed [5:0] sin0_index;
    wire signed [5:0] sin1_index;
    wire signed [5:0] sin2_index;
    wire signed [5:0] sin3_index;

    wire signed       sin0_signal;
    wire signed       sin1_signal;
    wire signed       sin2_signal;
    wire signed       sin3_signal;

    wire signed [31:0] sin0_int32;
    wire signed [31:0] sin1_int32;
    wire signed [31:0] sin2_int32;
    wire signed [31:0] sin3_int32;

    wire signed [31:0] sin0_signed;
    wire signed [31:0] sin1_signed;
    wire signed [31:0] sin2_signed;
    wire signed [31:0] sin3_signed;

    reg signed [15:0] sin0_q1_15_s2;
    reg signed [15:0] sin1_q1_15_s2;
    reg signed [15:0] sin2_q1_15_s2;
    reg signed [15:0] sin3_q1_15_s2;
    reg               any_nan_s2;

    wire [31:0] elems_enc;
    wire [7:0]  scale_enc;
    wire        overflow_enc;

    reg valid_s1;
    reg valid_s2;

    wire start_accepted;

    assign start_accepted = start && !busy;

    mx_decoder u_decoder (
        .elems_in(elems_in),
        .scale_in(scale_in),
        .out0_int(phase0_dec),
        .out1_int(phase1_dec),
        .out2_int(phase2_dec),
        .out3_int(phase3_dec),
        .any_nan(any_nan_dec)
    );

    phase_preprocess phase_preprocess_i (
        .angle0(phase0_s1),
        .angle1(phase1_s1),
        .angle2(phase2_s1),
        .angle3(phase3_s1),
        .lut_index0(sin0_index),
        .lut_index1(sin1_index),
        .lut_index2(sin2_index),
        .lut_index3(sin3_index),
        .negate0(sin0_signal),
        .negate1(sin1_signal),
        .negate2(sin2_signal),
        .negate3(sin3_signal)
    );

    LUT_Seno lut_i (
        .index0(sin0_index),
        .index1(sin1_index),
        .index2(sin2_index),
        .index3(sin3_index),
        .sin_value0(sin0_int32),
        .sin_value1(sin1_int32),
        .sin_value2(sin2_int32),
        .sin_value3(sin3_int32)
    );

    phase_postprocess phase_postprocess_i(
        .lut0(sin0_int32),
        .lut1(sin1_int32),
        .lut2(sin2_int32),
        .lut3(sin3_int32),
        .negate0(sin0_signal),
        .negate1(sin1_signal),
        .negate2(sin2_signal),
        .negate3(sin3_signal),
        .out0(sin0_signed),
        .out1(sin1_signed),
        .out2(sin2_signed),
        .out3(sin3_signed)
    );

    mx_encoder u_encoder (
        .in0_int(sin0_q1_15_s2),
        .in1_int(sin1_q1_15_s2),
        .in2_int(sin2_q1_15_s2),
        .in3_int(sin3_q1_15_s2),
        .elems_out(elems_enc),
        .scale_out(scale_enc),
        .overflow(overflow_enc)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            phase0_s1     <= 32'sd0;
            phase1_s1     <= 32'sd0;
            phase2_s1     <= 32'sd0;
            phase3_s1     <= 32'sd0;
            any_nan_s1    <= 1'b0;
            sin0_q1_15_s2 <= 16'sd0;
            sin1_q1_15_s2 <= 16'sd0;
            sin2_q1_15_s2 <= 16'sd0;
            sin3_q1_15_s2 <= 16'sd0;
            any_nan_s2    <= 1'b0;
            elems_out     <= 32'd0;
            scale_out     <= 8'd0;
            any_nan       <= 1'b0;
            overflow      <= 1'b0;
            busy          <= 1'b0;
            done          <= 1'b0;
            valid_s1      <= 1'b0;
            valid_s2      <= 1'b0;
        end else begin
            done <= 1'b0;

            if (start_accepted) begin
                phase0_s1  <= phase0_dec;
                phase1_s1  <= phase1_dec;
                phase2_s1  <= phase2_dec;
                phase3_s1  <= phase3_dec;
                any_nan_s1 <= any_nan_dec;
            end

            if (valid_s1) begin
                sin0_q1_15_s2 <= sin0_signed[15:0];
                sin1_q1_15_s2 <= sin1_signed[15:0];
                sin2_q1_15_s2 <= sin2_signed[15:0];
                sin3_q1_15_s2 <= sin3_signed[15:0];
                any_nan_s2    <= any_nan_s1;
            end

            if (valid_s2) begin
                elems_out <= elems_enc;
                scale_out <= scale_enc;
                any_nan   <= any_nan_s2;
                overflow  <= overflow_enc;
                done      <= 1'b1;
            end

            valid_s1 <= start_accepted;
            valid_s2 <= valid_s1;
            busy     <= start_accepted || valid_s1;
        end
    end
endmodule
