module x3x2x_notFull (clk , x, polinomio , rst );
    parameter lengthX = 8;
    input clk , rst ;
    input [ lengthX -1:0] x;
    output [3* lengthX -1:0] polinomio ;
    reg [15:0] x2;
    reg [3* lengthX -1:0] x3 , pol;

    always @( posedge clk or posedge rst ) begin
        if ( rst ) begin
            x2 <= 0;
            x3 <= 0;
            pol <= 0;
        end
        else begin
            x2 <= x*x;
            x3 <= x2 * x;
            pol <= x3 + x2 + x;
        end
    end
    assign polinomio = pol ;
endmodule