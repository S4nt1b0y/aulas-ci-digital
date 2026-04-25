module demux
#(
    parameter WIDTH = 5
)(
    input  wire[1:0]           sel,
    output reg    demux_out0,
    output reg    demux_out1,
    output reg    demux_out2,
    output reg    demux_out3
);

always @(*) begin
    demux_out0 = 0;
    demux_out1 = 0;
    demux_out2 = 0;
    demux_out3 = 0; 
    case (sel)
        2'b11: demux_out3 = 1;
        2'b10: demux_out2 = 1;
        2'b01: demux_out1 = 1;
        2'b00: demux_out0 = 1;
    endcase
end

endmodule