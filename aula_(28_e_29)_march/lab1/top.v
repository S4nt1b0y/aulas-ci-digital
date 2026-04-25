module top 
#(
    parameter WIDTH = 5
)
(
    input wire event0,
    input wire event1,
    input wire event2,
    input wire event3,
    input wire [WIDTH-1:0] sensor0_data,
    input wire [WIDTH-1:0] sensor1_data,
    input wire [WIDTH-1:0] sensor2_data,
    input wire [WIDTH-1:0] sensor3_data,
    output wire [WIDTH-1:0] sensor_output,
    output wire [3:0] status_output
);

wire [1:0] select_event;

encode_priority encode_priority_i(
    .in0(event0),
    .in1(event1),
    .in2(event2),
    .in3(event3),
    .sel(select_event)
);


mux mux_i(
    .in0(sensor0_data),
    .in1(sensor1_data),
    .in2(sensor2_data),
    .in3(sensor3_data),
    .sel(select_event),
    .mux_out(sensor_output)
);

demux demux_i(
    .sel(select_event),
    .demux_out0(status_output[0]),
    .demux_out1(status_output[1]),
    .demux_out2(status_output[2]),
    .demux_out3(status_output[3])
);
    
endmodule