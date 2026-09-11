module x3_enrolado (
    output reg [7:0] XPower ,
    output finished ,
    input [7:0] X,
    input clk , start
);
reg [7:0] ncount ;
assign finished = ( ncount == 0) ;
    always @( posedge clk )
        if ( start ) begin
            XPower <= X;
            ncount <= 2;
        end
        else if (! finished ) begin
            ncount <= ncount - 1;
            XPower <= XPower * X;
        end
endmodule