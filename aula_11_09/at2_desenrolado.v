module x3_curto (
    output reg [7:0] XPower ,
    input [7:0] X,
    input clk
);
reg [7:0] XPower1 , XPower2 ;
reg [7:0] X1 , X2;

always @( posedge clk ) begin
    // Pipeline Stage 1
    X1 <= X;
    XPower1 <= X;
    // Pipeline Stage 2
    X2 <= X1;
    XPower2 <= XPower1 * X1;
    // Pipeline stage 3
    XPower <= XPower2 * X2;
end
 endmodule