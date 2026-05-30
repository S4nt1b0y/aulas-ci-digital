module serializer
#(  
    parameter WIDTH = 8
)
 (
    input wire clk,
    input wire rst,
    input wire load,
    input wire [WIDTH-1:0] data_in,
    output reg serial_out,
    output reg ready
);
    localparam WIDTH_LOG2 = (WIDTH <= 1) ? 1 : $clog2(WIDTH);

    reg [WIDTH-1:0] shift_reg;
    reg [WIDTH_LOG2:0] bit_cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg <= {WIDTH{1'b0}};
            bit_cnt <= {WIDTH_LOG2{1'b0}};
            serial_out <= 0;
            ready <= 1;
        end else begin
            if (load) begin
                shift_reg <= data_in;
                bit_cnt <= WIDTH;
                ready <= 0;
            end else if (bit_cnt != {WIDTH_LOG2{1'b0}}) begin
                serial_out <= shift_reg[WIDTH-1];
                shift_reg <= shift_reg << 1;
                bit_cnt <= bit_cnt - 1;
            end 
            else begin
                serial_out <= ^data_in;
                ready <= 1;
            end
        end
    end

endmodule