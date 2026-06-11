module mx_loopback_top (
    input  wire [31:0] elems_in,
    input  wire [7:0]  scale_in,
    output wire [31:0] elems_out,
    output wire [7:0]  scale_out,
    output wire        any_nan,
    output wire        overflow
);
    wire signed [31:0] phase0_q16;
    wire signed [31:0] phase1_q16;
    wire signed [31:0] phase2_q16;
    wire signed [31:0] phase3_q16;

    mx_decoder u_decoder (
        .elems_in(elems_in),
        .scale_in(scale_in),
        .phase0_q16(phase0_q16),
        .phase1_q16(phase1_q16),
        .phase2_q16(phase2_q16),
        .phase3_q16(phase3_q16),
        .any_nan(any_nan)
    );

    mx_encoder u_encoder (
        .in0_q16(phase0_q16),
        .in1_q16(phase1_q16),
        .in2_q16(phase2_q16),
        .in3_q16(phase3_q16),
        .elems_out(elems_out),
        .scale_out(scale_out),
        .overflow(overflow)
    );
endmodule
