module apb4_slave #(
    parameter ADDR_WIDTH = 11,
    parameter DATA_WIDTH = 32
) (
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  psel,
    input  wire                  penable,
    input  wire                  pwrite,
    input  wire [ADDR_WIDTH-1:0] paddr,
    input  wire [DATA_WIDTH-1:0] pwdata,
    output wire [DATA_WIDTH-1:0] prdata,
    output wire                  pready,
    output wire                  pslverr,

    output reg                   bus_req,
    output reg                   bus_req_is_wr,
    output reg  [ADDR_WIDTH-1:0] bus_addr,
    output reg  [DATA_WIDTH-1:0] bus_wr_data,
    output reg  [DATA_WIDTH-1:0] bus_wr_biten,
    input  wire                  bus_ready,
    input  wire                  bus_err,
    input  wire [DATA_WIDTH-1:0] bus_rd_data
);
    localparam IDLE   = 2'b00;
    localparam SETUP  = 2'b01;
    localparam ACCESS = 2'b10;

    reg [1:0] current_state;
    reg [1:0] next_state;

    reg [ADDR_WIDTH-1:0] addr_reg;
    reg [DATA_WIDTH-1:0] wdata_reg;
    reg                  write_reg;

    wire capture_signals;
    wire transaction_complete;

    always @(*) begin
        case (current_state)
            IDLE: begin
                if (psel && !penable) next_state = SETUP;
                else next_state = IDLE;
            end
            SETUP: begin
                if (psel && penable) next_state = ACCESS;
                else if (!psel) next_state = IDLE;
                else next_state = SETUP;
            end
            ACCESS: begin
                if (transaction_complete) begin
                    if (psel && !penable) next_state = SETUP;
                    else next_state = IDLE;
                end else next_state = ACCESS;
            end
            default: next_state = IDLE;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) current_state <= IDLE;
        else current_state <= next_state;
    end

    assign capture_signals = (current_state == SETUP) && (next_state == ACCESS);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            addr_reg  <= {ADDR_WIDTH{1'b0}};
            wdata_reg <= {DATA_WIDTH{1'b0}};
            write_reg <= 1'b0;
        end else if (capture_signals) begin
            addr_reg  <= paddr;
            wdata_reg <= pwdata;
            write_reg <= pwrite;
        end
    end

    always @(*) begin
        bus_req       = 1'b0;
        bus_req_is_wr = 1'b0;
        bus_addr      = {ADDR_WIDTH{1'b0}};
        bus_wr_data   = {DATA_WIDTH{1'b0}};
        bus_wr_biten  = {DATA_WIDTH{1'b0}};

        if (current_state == ACCESS) begin
            bus_req       = 1'b1;
            bus_req_is_wr = write_reg;
            bus_addr      = addr_reg;
            bus_wr_data   = wdata_reg;
            bus_wr_biten  = write_reg ? {DATA_WIDTH{1'b1}} : {DATA_WIDTH{1'b0}};
        end
    end

    assign transaction_complete = bus_ready;
    assign pready  = (current_state == ACCESS) ? transaction_complete : 1'b0;
    assign prdata  = (current_state == ACCESS) ? bus_rd_data : {DATA_WIDTH{1'b0}};
    assign pslverr = (current_state == ACCESS) ? bus_err : 1'b0;
endmodule
