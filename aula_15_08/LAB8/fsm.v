`timescale 1ns/1ps

module fsm
#(
    parameter N = 8,
    parameter NLOG2 = (N <= 1) ? 1 : $clog2(N)
)
(
    input  wire             clk,
    input  wire             rst_n,
    input  wire             in_valid,
    input  wire             out_ready,
    output reg              in_ready,
    output reg              out_valid,
    output reg [NLOG2-1:0]  rom_addr,
    output reg [NLOG2-1:0]  buffer_rd_addr,
    output reg              mac_start,
    output reg              mac_valid,
    output reg              capture_result
);

localparam STATE_FILL     = 3'd0;
localparam STATE_ROM_WAIT = 3'd1;
localparam STATE_MAC_RUN  = 3'd2;
localparam STATE_CAPTURE  = 3'd3;
localparam STATE_HOLD     = 3'd4;

reg [2:0] state;
reg [2:0] next_state;
reg [NLOG2-1:0] fill_count;
reg [NLOG2-1:0] term_count;

wire sample_accept;
wire last_fill_sample;
wire last_term;
localparam [NLOG2-1:0] N_VALUE = N;

assign sample_accept = in_valid && in_ready;
assign last_fill_sample = (fill_count == N_VALUE - 1'b1);
assign last_term = (term_count == N_VALUE - 1'b1);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state      <= STATE_FILL;
        fill_count <= {NLOG2{1'b0}};
        term_count <= {NLOG2{1'b0}};
    end else begin
        state <= next_state;

        if (state == STATE_FILL && sample_accept && !last_fill_sample) begin
            fill_count <= fill_count + 1'b1;
        end

        if (state == STATE_ROM_WAIT) begin
            term_count <= {NLOG2{1'b0}};
        end else if (state == STATE_MAC_RUN) begin
            if (last_term) begin
                term_count <= {NLOG2{1'b0}};
            end else begin
                term_count <= term_count + 1'b1;
            end
        end
    end
end

always @(*) begin
    next_state = state;

    case (state)
        STATE_FILL: begin
            if (sample_accept && last_fill_sample) begin
                next_state = STATE_ROM_WAIT;
            end
        end

        STATE_ROM_WAIT: begin
            next_state = STATE_MAC_RUN;
        end

        STATE_MAC_RUN: begin
            if (last_term) begin
                next_state = STATE_CAPTURE;
            end
        end

        STATE_CAPTURE: begin
            next_state = STATE_HOLD;
        end

        STATE_HOLD: begin
            if (out_ready) begin
                next_state = STATE_FILL;
            end
        end

        default: begin
            next_state = STATE_FILL;
        end
    endcase
end

always @(*) begin
    in_ready       = (state == STATE_FILL);
    out_valid      = (state == STATE_HOLD);
    mac_start      = (state == STATE_ROM_WAIT);
    mac_valid      = (state == STATE_MAC_RUN);
    capture_result = (state == STATE_CAPTURE);
    buffer_rd_addr = term_count;

    case (state)
        STATE_ROM_WAIT: begin
            rom_addr = {NLOG2{1'b0}};
        end

        STATE_MAC_RUN: begin
            if (last_term) begin
                rom_addr = {NLOG2{1'b0}};
            end else begin
                rom_addr = term_count + 1'b1;
            end
        end

        default: begin
            rom_addr = {NLOG2{1'b0}};
        end
    endcase
end

endmodule
