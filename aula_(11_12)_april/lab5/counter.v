module counter
#(
    parameter COUNTER_WIDTH = 16
)
(
    input  wire clk, 
    input  wire a_rst,
    input  wire enable,
    input  wire load,
    input  wire mode,
    input  wire [COUNTER_WIDTH-1:0] data_in, 
    output reg  [COUNTER_WIDTH-1:0] counter_o 
);

always @(posedge clk or posedge a_rst) begin
    if (a_rst) begin
        counter_o <= {COUNTER_WIDTH{1'b0}};
    end else begin
        if (load) begin
            counter_o <= data_in;
        end else if (enable) begin
            counter_o <= mode ? counter_o + 1 : counter_o - 1;
        end
    end
end

endmodule