module mx_sin (
    input  wire [31:0] elems_in,
    input  wire [7:0]  scale_in,
    output wire [31:0] elems_out,
    output wire [7:0]  scale_out,
    output wire        any_nan,
    output wire        overflow
);
    wire signed [31:0] phase0_raw;
    wire signed [31:0] phase1_raw;
    wire signed [31:0] phase2_raw;
    wire signed [31:0] phase3_raw;

    wire signed [31:0] sin0_int32;
    wire signed [31:0] sin1_int32;
    wire signed [31:0] sin2_int32;
    wire signed [31:0] sin3_int32;

    wire signed [5:0] sin0_index;
    wire signed [5:0] sin1_index;
    wire signed [5:0] sin2_index;
    wire signed [5:0] sin3_index;

    wire signed sin0_signal;
    wire signed sin1_signal;
    wire signed sin2_signal;
    wire signed sin3_signal;

    wire signed [31:0] sin0_signed;
    wire signed [31:0] sin1_signed;
    wire signed [31:0] sin2_signed;
    wire signed [31:0] sin3_signed;

    mx_decoder u_decoder (
        .elems_in(elems_in),
        .scale_in(scale_in),
        .out0_int(phase0_raw),
        .out1_int(phase1_raw),
        .out2_int(phase2_raw),
        .out3_int(phase3_raw),
        .any_nan(any_nan)
    );

    phase_preprocess phase_preprocess_i (
        .angle0(phase0_raw),
        .angle1(phase1_raw),
        .angle2(phase2_raw),
        .angle3(phase3_raw),

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
        .in0_int(sin0_signed),
        .in1_int(sin1_signed),
        .in2_int(sin2_signed),
        .in3_int(sin3_signed),
        .elems_out(elems_out),
        .scale_out(scale_out),
        .overflow(overflow)
    );

endmodule    