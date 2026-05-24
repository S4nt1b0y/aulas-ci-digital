module mx_sin (
    wire [31:0] phase_in,
    wire clk,
    wire rst_n
);
    buffer_in buffer_in_i (
        .clk(clk),
    .rst(rst_n),
    .load,          
    input  wire [31:0]  dado_in,
    .clear,         
    output wire         req,           
    output reg  [31:0]  dado_out
    );
endmodule