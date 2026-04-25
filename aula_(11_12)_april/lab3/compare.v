module compare
#(
    parameter COUNTER_WIDTH = 16
)
(
    input [COUNTER_WIDTH-1:0] default_value, 
    input [COUNTER_WIDTH-1:0] counter_i,
    output isEqual
);

reg [COUNTER_WIDTH-1:0] counter;

assign isEqual = (default_value == counter_i);


endmodule