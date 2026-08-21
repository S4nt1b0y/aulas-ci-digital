module top #(
    parameter WIDTH = 8
  ) (
    input clk,
    input rst,
    input [6:0] cmd_in,
    input [WIDTH-1:0] din_1,
    input [WIDTH-1:0] din_2,
    input [WIDTH-1:0] din_3,
    output [WIDTH-1:0] dout_low,
    output [WIDTH-1:0] dout_high,
    output  cpu_rdy,
    output  zero,
    output  error
  );


  wire [WIDTH-1:0] mux_out_A, mux_out_B;
  wire [3:0] opcode;
  wire [2*WIDTH-1:0] out_ula, mem_out_data, out_mux;
  wire memoryWrite, memoryRead;
  wire [2*WIDTH-1:0] reg_dout;
  wire [1:0] flags, in_select_a, in_select_b;
  wire [6:0] cmd_in_reg;
  wire aluin_reg_en, aluout_reg_en, datain_reg_en,selmux2, invalid_data;

  mux4_registered #(.WIDTH(WIDTH)) regA (
                    .clk(clk), .rst(rst), .wr_en(aluin_reg_en),
                    .sel(in_select_a),
                    .in1(din_1), .in2(din_2), .in3(din_3), .in4(dout_high),
                    .out(mux_out_A)
                  );

  mux4_registered #(.WIDTH(WIDTH)) regB (
                    .clk(clk), .rst(rst), .wr_en(aluin_reg_en),
                    .sel(in_select_b),
                    .in1(din_1), .in2(din_2), .in3(din_3), .in4(dout_low),
                    .out(mux_out_B)
                  );

  ALU #(.WIDTH(WIDTH)) ulala (
        .in1(mux_out_A), .in2(mux_out_B),
        .op(opcode),
        .invalid_data(invalid_data),
        .out(out_ula),
        .zero(flags[1]),
        .error(flags[0])
      );

  memory #(.WIDTH(WIDTH)) memoria (
           .clk(clk), .memoryWrite(memoryWrite), .memoryRead(memoryRead),
           .memoryWriteData(reg_dout),
           .memoryAddress(mux_out_A),
           .memoryOutData(mem_out_data)
         );

  register_bank #(.WIDTH(7)) reg_cmd (
                  .clk(clk), .rst(rst), .wr_en(datain_reg_en),
                  .in(cmd_in),
                  .out(cmd_in_reg)
                );

  register_bank #(.WIDTH(2)) reg_flags (
                  .clk(clk), .rst(rst), .wr_en(aluout_reg_en),
                  .in(flags),
                  .out({zero,error})
                );

  register_bank #(.WIDTH(2*WIDTH)) reg_out (
                  .clk(clk), .rst(rst), .wr_en(aluout_reg_en),
                  .in(out_mux),
                  .out(reg_dout)
                );

  assign out_mux = selmux2 ? mem_out_data : out_ula;

  control fsm(
            .clk(clk),
            .rst(rst),
            .cmd_in(cmd_in_reg),
            .p_error(error),
            .aluin_reg_en(aluin_reg_en),
            .datain_reg_en(datain_reg_en),
            .memoryWrite(memoryWrite), .memoryRead(memoryRead), .selmux2(selmux2),
            .cpu_rdy(cpu_rdy),
            .aluout_reg_en(aluout_reg_en),
            .invalid_data(invalid_data),
            .in_select_a(in_select_a),
            .in_select_b(in_select_b),
            .opcode(opcode)
          );

  assign {dout_high,dout_low} = reg_dout;

endmodule
