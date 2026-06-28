module phase_preprocess (
    input  signed [31:0] angle0,
    input  signed [31:0] angle1,
    input  signed [31:0] angle2,
    input  signed [31:0] angle3,

    output reg [5:0] lut_index0,
    output reg [5:0] lut_index1,
    output reg [5:0] lut_index2,
    output reg [5:0] lut_index3,

    output reg negate0,
    output reg negate1,
    output reg negate2,
    output reg negate3
);

    localparam integer PI_DIV2  = 16384;
    localparam integer PI       = 32768;
    localparam integer PI3_DIV2 = 49152;
    localparam integer TWO_PI   = 65536;

    task automatic process_angle;
        input  signed [31:0] angle;
        output [5:0] lut_index;
        output       negate;

        integer angle_mod;
        integer angle_q1;
        integer idx;
        reg neg;

        begin

            angle_mod = angle % TWO_PI;

            if (angle_mod < 0)
                angle_mod = angle_mod + TWO_PI;

            neg = 1'b0;

            if (angle_mod < PI_DIV2) begin
                angle_q1 = angle_mod;
            end
            else if (angle_mod < PI) begin
                angle_q1 = PI - angle_mod;
            end
            else if (angle_mod < PI3_DIV2) begin
                angle_q1 = angle_mod - PI;
                neg = 1'b1;
            end
            else begin
                angle_q1 = TWO_PI - angle_mod;
                neg = 1'b1;
            end

            idx = (angle_q1 * 63) / PI_DIV2;

            if (idx < 0)
                idx = 0;
            else if (idx > 63)
                idx = 63;

            lut_index = idx[5:0];
            negate    = neg;

        end
    endtask

    always @(*) begin
        process_angle(angle0, lut_index0, negate0);
        process_angle(angle1, lut_index1, negate1);
        process_angle(angle2, lut_index2, negate2);
        process_angle(angle3, lut_index3, negate3);
    end

endmodule