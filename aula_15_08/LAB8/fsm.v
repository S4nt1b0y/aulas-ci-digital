module fsm 
#(
    parameter N = 8,
    parameter NLOG2 = 3
)(
    input wire clk,
    input wire rst_n,
    input wire in_valid,
    output wire in_ready,
    output reg room_addr,
    output wire start_proccess,
    output wire rst_mac,
    input wire out_ready
)

parameter IDLE              = 2'b00;
parameter BUFFER_FILLING    = 2'b01;
parameter RUNNING_DETECTION = 2'b10;
parameter WRITE_RESULT      = 2'b11;

    reg [1:0] state;
    reg [1:0] next_state;
    reg [NLOG2-1:0] count;

    wire buffer_fulled;


    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
            count <= 0;
        else begin
            state <= next_state;
            if(state == BUFFER_FILLING && in_valid) begin 
                count <= count + 1'b1;
            end
            if(state == BUFFER_FILLING && next_state == RUNNING_DETECTION) begin 
                count <= 0;
            end else if(state == RUNNING_DETECTION) begin 
                count <= count + 1'b1;
            end else if(state == WRITE_RESULT && out_ready) begin 
                rst_mac = 1'b1;
            end
        end
    end

    assign room_addr = count;

    always @(*) begin: state_decode
        in_ready = 1'b1;
        start_proccess = 1'b0;
        case (state)
            BUFFER_FILLING: begin 
                buffer_fulled = (count == N);
            end 
            RUNNING_DETECTION: begin 
                start_proccess = 1'b1;
                in_ready = 1'b0;
            end
        endcase
    end

    always @(*) begin: next_state

        next_state = state;
        case (state)
            IDLE: begin
                if(in_valid) begin 
                    next_state = BUFFER_FILLING;
                end
            end
            BUFFER_FILLING: begin 
                if(buffer_fulled) begin 
                    next_state = RUNNING_DETECTION;
                end
            end
            RUNNING_DETECTION: begin 
                if(correletion_done) begin 
                    next_state = WRITE_RESULT;
                end
            end
            WRITE_RESULT: begin
                if(out_ready) begin 
                    next_state = RUNNING_DETECTION;
                end
            end
        endcase
    end

endmodule