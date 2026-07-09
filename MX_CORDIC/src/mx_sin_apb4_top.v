`timescale 1ns/1ps

module mx_sin_apb4_top #(
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
    output wire                  pslverr
);
    localparam [ADDR_WIDTH-1:0] ADDR_CTRL      = {{(ADDR_WIDTH-6){1'b0}}, 6'h00};
    localparam [ADDR_WIDTH-1:0] ADDR_STATUS    = {{(ADDR_WIDTH-6){1'b0}}, 6'h04};
    localparam [ADDR_WIDTH-1:0] ADDR_ELEMS_IN  = {{(ADDR_WIDTH-6){1'b0}}, 6'h08};
    localparam [ADDR_WIDTH-1:0] ADDR_SCALE_IN  = {{(ADDR_WIDTH-6){1'b0}}, 6'h0c};
    localparam [ADDR_WIDTH-1:0] ADDR_ELEMS_OUT = {{(ADDR_WIDTH-6){1'b0}}, 6'h10};
    localparam [ADDR_WIDTH-1:0] ADDR_SCALE_OUT = {{(ADDR_WIDTH-6){1'b0}}, 6'h14};

    wire                  bus_req;
    wire                  bus_req_is_wr;
    wire [ADDR_WIDTH-1:0] bus_addr;
    wire [DATA_WIDTH-1:0] bus_wr_data;
    wire [DATA_WIDTH-1:0] bus_wr_biten;
    wire                  bus_ready;
    wire                  bus_err;
    reg  [DATA_WIDTH-1:0] bus_rd_data;

    reg [31:0] elems_in_reg;
    reg [7:0]  scale_in_reg;
    reg [31:0] elems_out_reg;
    reg [7:0]  scale_out_reg;
    reg        any_nan_reg;
    reg        overflow_reg;
    reg        done_reg;
    reg        mx_start_reg;

    wire [31:0] sin_elems_out;
    wire [7:0]  sin_scale_out;
    wire        sin_any_nan;
    wire        sin_overflow;
    wire        sin_busy;
    wire        sin_done;

    wire access_valid;
    wire write_access;
    wire start_pulse;
    wire clear_done_pulse;
    wire busy_status;

    apb4_slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_apb4_slave (
        .clk(clk),
        .rst_n(rst_n),
        .psel(psel),
        .penable(penable),
        .pwrite(pwrite),
        .paddr(paddr),
        .pwdata(pwdata),
        .prdata(prdata),
        .pready(pready),
        .pslverr(pslverr),
        .bus_req(bus_req),
        .bus_req_is_wr(bus_req_is_wr),
        .bus_addr(bus_addr),
        .bus_wr_data(bus_wr_data),
        .bus_wr_biten(bus_wr_biten),
        .bus_ready(bus_ready),
        .bus_err(bus_err),
        .bus_rd_data(bus_rd_data)
    );

    mx_sin u_mx_sin (
        .clk(clk),
        .rst_n(rst_n),
        .start(mx_start_reg),
        .elems_in(elems_in_reg),
        .scale_in(scale_in_reg),
        .elems_out(sin_elems_out),
        .scale_out(sin_scale_out),
        .any_nan(sin_any_nan),
        .overflow(sin_overflow),
        .busy(busy_status),
        .done(sin_done)
    );

    assign access_valid = (bus_addr == ADDR_CTRL)      ||
                          (bus_addr == ADDR_STATUS)    ||
                          (bus_addr == ADDR_ELEMS_IN)  ||
                          (bus_addr == ADDR_SCALE_IN)  ||
                          (bus_addr == ADDR_ELEMS_OUT) ||
                          (bus_addr == ADDR_SCALE_OUT);

    assign write_access     = bus_req && bus_req_is_wr && access_valid;
    assign start_pulse      = write_access && (bus_addr == ADDR_CTRL) && bus_wr_data[0] && !busy_status;
    assign clear_done_pulse = write_access && (bus_addr == ADDR_CTRL) && bus_wr_data[1];
    assign bus_ready        = 1'b1;
    assign bus_err          = bus_req && !access_valid;

    always @(*) begin
        bus_rd_data = {DATA_WIDTH{1'b0}};

        if (access_valid) begin
            case (bus_addr)
                ADDR_CTRL:
                    bus_rd_data = {DATA_WIDTH{1'b0}};
                ADDR_STATUS:
                    bus_rd_data = {{(DATA_WIDTH-4){1'b0}},
                                   overflow_reg, any_nan_reg, done_reg, busy_status};
                ADDR_ELEMS_IN:
                    bus_rd_data = elems_in_reg;
                ADDR_SCALE_IN:
                    bus_rd_data = {{(DATA_WIDTH-8){1'b0}}, scale_in_reg};
                ADDR_ELEMS_OUT:
                    bus_rd_data = elems_out_reg;
                ADDR_SCALE_OUT:
                    bus_rd_data = {{(DATA_WIDTH-8){1'b0}}, scale_out_reg};
                default:
                    bus_rd_data = {DATA_WIDTH{1'b0}};
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            elems_in_reg        <= 32'd0;
            scale_in_reg        <= 8'd0;
            elems_out_reg       <= 32'd0;
            scale_out_reg       <= 8'd0;
            any_nan_reg         <= 1'b0;
            overflow_reg        <= 1'b0;
            done_reg            <= 1'b0;
            mx_start_reg        <= 1'b0;
        end else begin
            mx_start_reg <= 1'b0;

            if (sin_done) begin
                elems_out_reg       <= sin_elems_out;
                scale_out_reg       <= sin_scale_out;
                any_nan_reg         <= sin_any_nan;
                overflow_reg        <= sin_overflow;
                done_reg            <= 1'b1;
            end

            if (clear_done_pulse) begin
                done_reg <= 1'b0;
            end

            if (write_access) begin
                case (bus_addr)
                    ADDR_ELEMS_IN:
                        elems_in_reg <= bus_wr_data[31:0];
                    ADDR_SCALE_IN:
                        scale_in_reg <= bus_wr_data[7:0];
                    default: begin
                    end
                endcase
            end

            if (start_pulse) begin
                mx_start_reg <= 1'b1;
                done_reg     <= 1'b0;
            end
        end
    end
endmodule
