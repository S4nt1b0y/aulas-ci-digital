module counter
#(
    parameter COUNTER_WIDTH = 16
)
(
    input  clk, 
    input  rst,
    input  en_n,
    output reg [COUNTER_WIDTH-1:0] counter_o 
);


always @(posedge clk or posedge rst) begin
    if (rst == 1'b1) begin
        counter_o <= {COUNTER_WIDTH{1'b0}};
    end else begin
        if (en_n == 1'b1)
            counter_o <= counter_o + 1;
    end
end

endmodule