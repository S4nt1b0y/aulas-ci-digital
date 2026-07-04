module mx_loopback_top (
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

    mx_decoder u_decoder (
        .elems_in(elems_in),
        .scale_in(scale_in),
        .out0_int(phase0_raw),
        .out1_int(phase1_raw),
        .out2_int(phase2_raw),
        .out3_int(phase3_raw),
        .any_nan(any_nan)
    );

    mx_encoder u_encoder (
        .in0_int(phase0_raw),
        .in1_int(phase1_raw),
        .in2_int(phase2_raw),
        .in3_int(phase3_raw),
        .elems_out(elems_out),
        .scale_out(scale_out),
        .overflow(overflow)
    );
endmodule
