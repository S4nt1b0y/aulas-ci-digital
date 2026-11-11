// mac_param.v - Unidade MAC com larguras definidas por macros (Genus-friendly)

`ifndef DATA_WIDTH
    `define DATA_WIDTH 8
`endif

`ifndef NUM_TERMS
    `define NUM_TERMS 1024
`endif

`ifndef ACC_WIDTH
    `define ACC_WIDTH 26
`endif

`ifndef CNT_WIDTH
    `define CNT_WIDTH 11
`endif

module mac_param(
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire                     start,
    input  wire                     valid,
    input  wire [`DATA_WIDTH-1:0]   a,
    input  wire [`DATA_WIDTH-1:0]   b,
    output reg                      busy,
    output reg                      done,
    output reg  [`ACC_WIDTH-1:0]    result
);

    localparam DATA_WIDTH = `DATA_WIDTH;
    localparam NUM_TERMS  = `NUM_TERMS;
    localparam ACC_WIDTH  = `ACC_WIDTH;
    localparam CNT_WIDTH  = `CNT_WIDTH;

    reg [ACC_WIDTH-1:0] acc;
    reg [CNT_WIDTH-1:0] cnt;

    wire [2*DATA_WIDTH-1:0] prod = a * b;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            busy   <= 1'b0;
            done   <= 1'b0;
            acc    <= 0;
            cnt    <= 0;
            result <= 0;
        end else begin
            done <= 1'b0;

            if (start && !busy) begin
                busy   <= 1'b1;
                acc    <= 0;
                cnt    <= 0;
                result <= 0;
            end

            if (busy && valid) begin
                if (cnt == NUM_TERMS - 1) begin
                    result <= acc +
                              {{(ACC_WIDTH - 2*DATA_WIDTH){1'b0}}, prod};
                    busy   <= 1'b0;
                    done   <= 1'b1;
                end else begin
                    acc <= acc +
                           {{(ACC_WIDTH - 2*DATA_WIDTH){1'b0}}, prod};
                    cnt <= cnt + 1'b1;
                end
            end
        end
    end

endmodule