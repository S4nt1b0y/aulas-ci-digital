`timescale 1ns/1ps

module restoring_division_tb;

 parameter WIDTH = 4;

 // sinais
 reg clk;
 reg rst;
 reg start;
 reg [WIDTH-1:0] dividendo;
 reg [WIDTH-1:0] divisor;
 wire [WIDTH-1:0] quociente;
 wire [WIDTH-1:0] resto;
 wire done;
 wire div_zero;
 wire quociente_zero;
 wire resto_zero;
 wire resto_negativo;

 reg [WIDTH-1:0] quociente_expected;
 reg [WIDTH-1:0] resto_expected;
 // DUT

 restoring_division_top #(.WIDTH(WIDTH)) DUT
 ( .clk(clk),
 .rst(rst),
 .start(start),
 .dividendo(dividendo),
 .divisor(divisor),
 .quociente(quociente),
 .resto(resto),
 .done(done)
 );

always #5 clk = ~clk;

task expected_divide;

 input [WIDTH-1:0] opA;
 input [WIDTH-1:0] opB;
begin

 @(posedge clk);

 start = 1'b1;
 dividendo = opA;
 divisor = opB;

 while (!done) begin
    @(posedge clk);
 end
 
 quociente_expected = dividendo / divisor;
 resto_expected = dividendo % divisor;
 
 $display("Quociente ex: %d, Quociente got: %d", quociente_expected, quociente );
 $display("resto ex: %d, resto got: %d", resto_expected, resto );

end

endtask




 // sequência de testes

 initial
 begin
 clk = 0;
 $dumpfile("wave.vcd");
 $dumpvars(0, restoring_division_tb);

 // inicialização

 rst = 1'b1;

 start = 0;

 dividendo = 0;
 divisor = 0;

 #20;

 rst = 1'b0;

 #20;

 // CASOS OBRIGATÓRIOS
 expected_divide(8'd11, 8'd3);

 // fim

 $display("FIM DA SIMULACAO");
 #20;

 $finish;

 end

endmodule

// iverilog -o sim restoring_division_tb tb_restoring_division.v restoring_division_top.v restoring_division_ctrl.v restoring_division_datapath.v