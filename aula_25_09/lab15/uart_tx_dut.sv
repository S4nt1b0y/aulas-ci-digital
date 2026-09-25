module uart_tx_dut #(
  parameter int CLK_FREQ_HZ = 10_000_000,
  parameter int BAUD_RATE   = 100_000
)(
  input  logic       clk,
  input  logic       rst_n,
  input  logic       tx_start,
  input  logic [7:0] tx_data,
  output logic       tx_busy,
  output logic       tx_serial,
  output logic       tx_done
);
  localparam int CLKS_PER_BIT = CLK_FREQ_HZ / BAUD_RATE;

  typedef enum logic [2:0] { IDLE, START, DATA, STOP, DONE } state_t;
  state_t state;

  localparam int CNT_W =
    (CLKS_PER_BIT <= 1) ? 1 : $clog2(CLKS_PER_BIT);

  logic [CNT_W-1:0] clk_count;
  logic [2:0]       bit_index;
  logic [7:0]       data_latched;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= IDLE; tx_serial <= 1'b1; tx_busy <= 1'b0;
      tx_done <= 1'b0; clk_count <= '0; bit_index <= '0;
      data_latched <= '0;
    end else begin
      tx_done <= 1'b0;
      case (state)
        IDLE: begin
          tx_serial <= 1'b1;
          tx_busy   <= 1'b0;
          clk_count <= '0;
          if (tx_start) begin
            data_latched <= tx_data;
            tx_busy      <= 1'b1;
            state        <= START;
          end
        end
        START: begin
          tx_serial <= 1'b0;
          tx_busy   <= 1'b1;
          if (clk_count == CLKS_PER_BIT-1) begin
            clk_count <= '0;
            bit_index <= '0;
            state     <= DATA;
          end else begin
            clk_count <= clk_count + 1'b1;
          end
        end
        DATA: begin
          tx_serial <= data_latched[bit_index];
          tx_busy   <= 1'b1;
          if (clk_count == CLKS_PER_BIT-1) begin
            clk_count <= '0;
            if (bit_index == 3'd7) state <= STOP;
            else bit_index <= bit_index + 1'b1;
          end else begin
            clk_count <= clk_count + 1'b1;
          end
        end
        STOP: begin
          tx_serial <= 1'b1;
          tx_busy   <= 1'b1;
          if (clk_count == CLKS_PER_BIT-1) begin
            clk_count <= '0;
            state     <= DONE;
          end else begin
            clk_count <= clk_count + 1'b1;
          end
        end
        DONE: begin
          tx_serial <= 1'b1;
          tx_busy   <= 1'b0;
          tx_done   <= 1'b1;
          state     <= IDLE;
        end
        default: state <= IDLE;
      endcase
    end
  end
endmodule
