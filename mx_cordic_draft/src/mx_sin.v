module mx_sin (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    input  wire        op_mode,
    input  wire [31:0] in_elems,
    input  wire [7:0]  in_scale,
    output wire        busy,
    output wire        done,
    output reg         input_valid,
    output reg         output_valid,
    output reg         error_overflow,
    output wire [31:0] out_elems,
    output wire [7:0]  out_scale
);

    wire signed [31:0] phase0_q16, phase1_q16, phase2_q16, phase3_q16;
    wire any_nan;

    mx_decoder u_dec (
        .elems_in(in_elems),
        .scale_in(in_scale),
        .phase0_q16(phase0_q16), .phase1_q16(phase1_q16),
        .phase2_q16(phase2_q16), .phase3_q16(phase3_q16),
        .any_nan(any_nan)
    );

    reg signed [31:0] trig0_r, trig1_r, trig2_r, trig3_r;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            trig0_r <= 32'sd0;
            trig1_r <= 32'sd0;
            trig2_r <= 32'sd0;
            trig3_r <= 32'sd0;
        end else begin
            trig0_r <= phase0_q16;
            trig1_r <= phase1_q16;
            trig2_r <= phase2_q16;
            trig3_r <= phase3_q16;
        end
    end

    wire        enc_ovf;

    mx_encoder u_enc (
        .in0_q16(trig0_r), .in1_q16(trig1_r), .in2_q16(trig2_r), .in3_q16(trig3_r),
        .elems_out(out_elems), .scale_out(out_scale), .overflow(enc_ovf)
    );

endmodule
