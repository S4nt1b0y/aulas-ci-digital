module rom (
    input  wire        clk,
    input  wire        cs, 
    input  wire [4:0]  addr,
    output reg  [7:0]  data_out
);

    reg [7:0] rom [0:15];

    initial begin
        rom[0]  = 8'd0;
        rom[1]  = 8'd1;
        rom[2]  = 8'd1;
        rom[3]  = 8'd2;
        rom[4]  = 8'd3;
        rom[5]  = 8'd5;
        rom[6]  = 8'd8;
        rom[7]  = 8'd13;
        rom[8]  = 8'd21;
        rom[9]  = 8'd34;
        rom[10] = 8'd55;
        rom[11] = 8'd89;
        rom[12] = 8'd144;
        rom[13] = 8'd233;
        rom[14] = 8'd121;
        rom[15] = 8'd98; 
    end

    always @(posedge clk) begin
        if(cs) begin 
            data_out <= rom[addr];
        end
    end

endmodule