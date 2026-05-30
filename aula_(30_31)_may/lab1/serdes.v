module serdes #(parameter WIDTH = 8)
(
	input wire clk,
	input wire rst,
	input wire load,
	input wire [WIDTH-1:0] data_in,
	input wire enable,
	output wire [WIDTH-1:0] data_out,
	output wire done,
	output wire error
);

	wire serial;
	wire ready_serializer;
	wire ready_deserializer;
	 
	serializer #(.WIDTH(WIDTH)) s (.clk(clk), .rst(rst), .load(load), .data_in(data_in), .serial_out(serial), .ready(ready_serializer));
	deserializer #(.WIDTH(WIDTH)) d (.clk(clk), .rst(rst), .serial_in(serial), .enable(enable), .data_out(data_out), .done(done), .ready(ready_deserializer), .error(error));

endmodule
