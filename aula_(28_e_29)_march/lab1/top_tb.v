module top_tb;


localparam WIDTH = 5;

reg event0;
reg event1;
reg event2;
reg event3;
reg [WIDTH-1:0] sensor0_data;
reg [WIDTH-1:0] sensor1_data;
reg [WIDTH-1:0] sensor2_data;
reg [WIDTH-1:0] sensor3_data;
wire [WIDTH-1:0] sensor_output;
wire [3:0] status_output;


top dut(
    .event0(event0),
    .event1(event1),
    .event2(event2),
    .event3(event3),
    .sensor0_data(sensor0_data),
    .sensor1_data(sensor1_data),
    .sensor2_data(sensor2_data),
    .sensor3_data(sensor3_data),

    .sensor_output(sensor_output),
    .status_output(status_output)
); 

task expect;
    input [4:0] exp_output;
    input [3:0] exp_status;
    if (sensor_output != exp_output || status_output != exp_status ) begin
      $display("\nTEST FAILED");
      $display("event0 = %b, event1 = %b, event2 = %b, event4 = %b", event0,event1,event2,event3);
      $display("sensor0_data = %b, sensor1_data = %b, sensor2_data = %b, sensor4_data = %b", sensor0_data,sensor1_data,sensor2_data,sensor3_data);
      $display("data_out = %b, status_data = %b", sensor_output, status_output);
      $finish;
    end
  endtask

initial 
 begin
    // Testando MUX
  event0 = 0;
  event1 = 1;
  event2 = 0;
  event3 = 0;
  sensor0_data = 5'b10101;
  sensor1_data = 5'b00000;
  sensor2_data = 5'b11111;
  sensor3_data = 5'b01010;
  #1 expect (5'b00000, 4'b0010);
  
  #1;
  event0 = 0;
  event1 = 0;
  event2 = 1;
  event3 = 0;
  sensor0_data = 5'b10101;
  sensor1_data = 5'b00000;
  sensor2_data = 5'b11111;
  sensor3_data = 5'b01010;
  #1 expect (5'b11111, 4'b0100);
  
  #1;
  event0 = 0;
  event1 = 0;
  event2 = 0;
  event3 = 1;
  sensor0_data = 5'b10101;
  sensor1_data = 5'b00000;
  sensor2_data = 5'b11111;
  sensor3_data = 5'b01010;
  #1 expect (5'b01010, 4'b1000);
  
  //TEST DE PRIORIDADE
  event0 = 0;
  event1 = 1;
  event2 = 0;
  event3 = 1;
  sensor0_data = 5'b10101;
  sensor1_data = 5'b00000;
  sensor2_data = 5'b11111;
  sensor3_data = 5'b01010;
  #1 expect (5'b01010, 4'b1000);

  event0 = 1;
  event1 = 1;
  event2 = 1;
  event3 = 0;
  sensor0_data = 5'b10101;
  sensor1_data = 5'b00000;
  sensor2_data = 5'b11111;
  sensor3_data = 5'b01010;
  #1 expect (5'b11111, 4'b0100);



  $finish; // let's stop the simulation here.
 end

 initial begin
  $dumpfile("top_tb.vcd");
  $dumpvars(0, top_tb);
end

endmodule