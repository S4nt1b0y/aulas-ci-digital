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

    mx_decoder u_decoder (
        .elems_in(elems_in),
        .scale_in(scale_in),
        .out0_int(phase0_raw),
        .out1_int(phase1_raw),
        .out2_int(phase2_raw),
        .out3_int(phase3_raw),
        .any_nan(any_nan)
    );

    LUT_Seno lut_i (
        .index0(phase0_raw),
        .index1(phase1_raw),
        .index2(phase2_raw),
        .index3(phase3_raw),
        .sin_value0(sin0_int32),
        .sin_value1(sin1_int32),
        .sin_value2(sin2_int32),
        .sin_value3(sin3_int32)
    );

    mx_encoder u_encoder (
        .in0_int(sin0_int32),
        .in1_int(sin1_int32),
        .in2_int(sin2_int32),
        .in3_int(sin3_int32),
        .elems_out(elems_out),
        .scale_out(scale_out),
        .overflow(overflow)
    );

endmodule    