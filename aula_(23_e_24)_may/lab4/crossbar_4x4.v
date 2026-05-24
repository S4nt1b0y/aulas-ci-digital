module crossbar_4x4 (
    input  wire [7:0] in0,in1, in2,in3,
    input  wire [1:0] sel0, sel1, sel2, sel3,  
    output reg  [7:0] out0, out1, out2, out3
);
    always @(*) begin
        case (sel0)
            2'd0: out0 = in0;
            2'd1: out0 = in1;
            2'd2: out0 = in2;
            2'd3: out0 = in3;
            default: out0 = 8'b0;
        endcase
    end
    always @(*) begin
        case (sel1)
            2'd0: out1 = in0;
            2'd1: out1 = in1;
            2'd2: out1 = in2;
            2'd3: out1 = in3;
            default: out1 = 8'b0;
        endcase
    end
    always @(*) begin
        case (sel2)
            2'd0: out2 = in0;
            2'd1: out2 = in1;
            2'd2: out2 = in2;
            2'd3: out2 = in3;
            default: out2 = 8'b0;
        endcase
    end
    always @(*) begin
        case (sel3)
            2'd0: out3 = in0;
            2'd1: out3 = in1;
            2'd2: out3 = in2;
            2'd3: out3 = in3;
            default: out3 = 8'b0;
        endcase
    end
endmodule
