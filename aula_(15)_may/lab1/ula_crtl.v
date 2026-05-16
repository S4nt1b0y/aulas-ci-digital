module ula_ctrl
#(parameter WIDTH = 8)
(
    input   wire                clk,
    input   wire                rst,
    input   wire                request_valid,
    input   wire[WIDTH-1:0]     alu_result,
    output  reg                 enable,  
    output  reg                 ip_valid,
    output  reg[WIDTH-1:0]      ip_result,
    output  reg                 ip_ready
);

localparam IDLE                  = 2'b00;
localparam OPERATION_IN_PROGRESS = 2'b01;
localparam SEND_RESULT           = 2'b10;

reg [1:0] state, next_state;

always @(posedge clk or posedge rst) begin
    if (rst)
        state <= IDLE;
    else
        state <= next_state;
end


always @(posedge clk) begin //decode signals
    ip_ready = 1;
    ip_valid = 0;
    ip_result = {WIDTH{1'b0}};
    enable = 0;
    case (state)
        IDLE:
            ip_ready = 1;
        OPERATION_IN_PROGRESS: begin
            ip_ready = 0;
            enable = 1;
        end
        SEND_RESULT: 
            ip_result = alu_result;
    endcase
        
end

always @(posedge clk) begin //transaction logic
    next_state = state;
    case (state) 
        IDLE:
            if(ip_ready && request_valid) begin
                next_state = OPERATION_IN_PROGRESS;
            end
        OPERATION_IN_PROGRESS: next_state = SEND_RESULT;
        SEND_RESULT: next_state = IDLE;
    endcase
end

endmodule