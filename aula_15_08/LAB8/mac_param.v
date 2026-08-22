`timescale 1ns/1ps

module mac_param
#(
    parameter DATA_WIDTH = 16,
    parameter NUM_TERMS = 8,
    parameter ACC_WIDTH = (2 * DATA_WIDTH) + ((NUM_TERMS <= 1) ? 1 : $clog2(NUM_TERMS))
)
(
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire                         start,
    input  wire                         valid,
    input  wire signed [DATA_WIDTH-1:0] a,
    input  wire signed [DATA_WIDTH-1:0] b,
    output reg                          busy,
    output reg                          done,
    output reg signed [ACC_WIDTH-1:0]   result
);

localparam COUNT_WIDTH = (NUM_TERMS <= 1) ? 1 : $clog2(NUM_TERMS);
localparam [COUNT_WIDTH-1:0] NUM_TERMS_VALUE = NUM_TERMS;

reg [COUNT_WIDTH-1:0] count;
wire signed [(2*DATA_WIDTH)-1:0] product;
wire signed [ACC_WIDTH-1:0] product_ext;

assign product = a * b;
assign product_ext = {{(ACC_WIDTH-(2*DATA_WIDTH)){product[(2*DATA_WIDTH)-1]}}, product};

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        result <= {ACC_WIDTH{1'b0}};
        busy   <= 1'b0;
        done   <= 1'b0;
        count  <= {COUNT_WIDTH{1'b0}};
    end else begin
        done <= 1'b0;

        if (start) begin
            result <= {ACC_WIDTH{1'b0}};
            busy   <= 1'b1;
            count  <= {COUNT_WIDTH{1'b0}};
        end else if (valid && busy) begin
            result <= result + product_ext;

            if (count == NUM_TERMS_VALUE - 1'b1) begin
                busy  <= 1'b0;
                done  <= 1'b1;
                count <= {COUNT_WIDTH{1'b0}};
            end else begin
                count <= count + 1'b1;
            end
        end
    end
end

endmodule
