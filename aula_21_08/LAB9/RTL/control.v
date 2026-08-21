 module control(
 input clk,
 input rst,
 input [6:0] cmd_in,
 input p_error,
 output reg aluin_reg_en,
 output reg datain_reg_en,
 output reg memoryWrite, memoryRead, selmux2, 
 output reg cpu_rdy,
 output reg aluout_reg_en,
 output invalid_data,
 output [1:0]  in_select_a,
 output [1:0]  in_select_b,
 output [3:0]  opcode
 );

 localparam clear = 0, fetch = 1, exec = 2, store = 3;
 reg [1:0] state;

 always@(posedge clk, posedge rst) begin
    if(rst)
        state <= clear;
    else
        case(state)
            clear: state <= fetch;
            fetch: state <= exec;
            exec: state <= store;
            store: state <= fetch;
            default: state <= clear;
        endcase
 end

always@(*) begin
    aluin_reg_en=0;
    datain_reg_en=0;
    memoryWrite=0; 
    memoryRead=0;
    selmux2=0; 
    cpu_rdy=0;
    aluout_reg_en=0;
    case(state)
        clear: datain_reg_en=1;
        fetch:  begin aluin_reg_en = 1; end
        exec:   begin 
                    case(opcode)
                        0,1,2,3: aluout_reg_en=1;
                        5:begin aluout_reg_en=1; 
				memoryRead = 1; 
				selmux2 = 1; 
			end
                    endcase
                end
        store:  begin   cpu_rdy = 1; 
			datain_reg_en=1; 
                    	if (opcode == 4'b0110) 
                        	memoryWrite = 1; 
                end
    endcase
end

 assign in_select_a = cmd_in[6:5]; 
 assign in_select_b = cmd_in[4:3]; 
 assign opcode = {1'b0,cmd_in[2:0]};
 assign invalid_data = (in_select_a == 2'b11 || in_select_b == 2'b11) & p_error;

 endmodule