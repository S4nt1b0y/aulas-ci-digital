module mac_param #(
    parameter DATA_WIDTH = 8,
    parameter NUM_TERMS = 1024,
    localparam ACC_WIDTH  = 2*DATA_WIDTH + $clog2(NUM_TERMS)
) (
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire valid,
    input wire [DATA_WIDTH-1:0] a,
    input wire [DATA_WIDTH-1:0] b,
    output reg busy,
    output reg done,
    output reg [ACC_WIDTH-1:0] result
);

reg [$clog2(NUM_TERMS)-1:0] count;

always @(posedge clk, negedge rst_n ) begin 
    if(!rst_n) begin 
        result <= {ACC_WIDTH{1'b0}};
        done <= 0;
        busy <= 0;
        count <= 0;
    end else begin 
        if(start && !busy) begin 
            busy <= 1;
            count <= 0;
            result <= {ACC_WIDTH{1'b0}};
        end else if (valid && busy) begin 
            result <= result + (a*b);
            count <= count + 1;
        end
        if(count == NUM_TERMS-1) begin  
            done <= 1;
            busy <= 0;
            count <= 0;
        end else begin 
            done <= 0;
        end 
    end
end

endmodule