module counter 
#(
    parameter WIDTH = 5
)(
    input wire[WIDTH-1:0] cnt_in,
    input wire enab,
    input wire load,
    input wire clk,
    input wire rst,
    output wire[WIDTH-1:0] cnt_out
);

reg [WIDTH-1:0] cnt;

assign cnt_out = cnt;

always @(posedge clk) begin
if(rst)begin 
    cnt = {WIDTH{1'b0}};
end
else begin 
    if(load) begin 
        cnt <= cnt_in; 
    end else if(enab) begin
        cnt <= cnt+1;
    end
    
end

end

endmodule