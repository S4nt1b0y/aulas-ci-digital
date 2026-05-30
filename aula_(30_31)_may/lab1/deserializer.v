module deserializer 
#(  
    parameter WIDTH = 8
)
(
    input wire clk,
    input wire rst,
    input wire serial_in,
    input wire enable,
    output reg [WIDTH-1:0] data_out,
    output reg done,
    output reg error,
    output reg ready
);
    
    localparam WIDTH_LOG2 = (WIDTH <= 1) ? 1 : $clog2(WIDTH+1);

    reg [WIDTH-1:0] shift_reg;
    reg [WIDTH_LOG2:0] bit_cnt;
    reg inner_done;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg <= {WIDTH{1'b0}};
            bit_cnt <= {WIDTH_LOG2{1'b0}};
            done <= 0;
            ready <= 1;
            inner_done <= 0;
        end else if (enable) begin

            if (ready)
                ready <= 1'b0;

            
            shift_reg <= {shift_reg[WIDTH-2:0], serial_in};
            bit_cnt <= bit_cnt + 1;
            if (bit_cnt == WIDTH) begin
                data_out <= {shift_reg[WIDTH-2:0], serial_in};
                inner_done <= 1;
            end
            if(inner_done) begin
                error <= serial_in != (^data_out);
                done  <= 1;
                ready <= 1;
            end else begin
                done <= 0;
            end
        end
    end

endmodule