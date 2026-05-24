module buffer_out(
    input  wire       clk,
    input  wire       rst,
    input  wire       grant,          
    input  wire [7:0] dado_in,          
    output reg  [7:0] dado_out
);

always @(posedge clk or posedge rst) begin
        if (rst) 
            dado_out  <= 8'b0;
         else
            if (grant) 
                dado_out <= dado_in;
    end

endmodule