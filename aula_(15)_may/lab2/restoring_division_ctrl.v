module restoring_division_ctrl
#(parameter WIDTH = 8)
(
    input   wire                clk,
    input   wire                rst,
    input   wire                start,
    input   wire[WIDTH-1:0]     divisor,
    input   wire[WIDTH-1:0]     dividendo,
    input   wire[WIDTH-1:0]     a,
    input   wire[WIDTH-1:0]     n,
    output  reg                 load,  
    output  reg[2:0]           opcode,
    output  reg                 done,
    output  reg                 invalid_operation
);

localparam IDLE                  = 4'b0000;
localparam OPERAND_SANITIZE      = 4'b0001;
localparam LOAD_OPERANDS         = 4'b0010;
localparam SHIFT_AQ              = 4'b0011;
localparam A_MODIFY              = 4'b0100;
localparam Q_BIT_FLIP            = 4'b0101;
localparam N_SUBTRATION          = 4'b0110;
localparam N_VERIFICATION        = 4'b0111;
localparam A_CORRECTION          = 4'b1000;
localparam FINISH                = 4'b1001;

reg [3:0] state, next_state;

always @(posedge clk or posedge rst) begin
    if (rst)
        state <= IDLE;
    else
        state <= next_state;
end


always @(*) begin //decode signals
    load = 0;
    opcode = 3'b00;
    done = 0;
    invalid_operation = 0;
    case (state)
        OPERAND_SANITIZE: begin
            invalid_operation = (divisor == {WIDTH{1'b0}});
        end
        LOAD_OPERANDS: 
            load = 1;
        SHIFT_AQ:
            opcode = 3'b001; //shift
        A_MODIFY:
            if(a[WIDTH-1]) begin
                opcode = 3'b010; //soma
            end else begin
                opcode = 3'b011; //sub
            end
        Q_BIT_FLIP: 
             if(a[WIDTH-1]) begin
                opcode = 3'b100; //set 1 em Q[1]
            end else begin
                opcode = 3'b101; //set 0 em Q[0]
            end
        N_SUBTRATION: opcode = 3'b110; //subtrai n
        A_CORRECTION: 
            if(a[WIDTH-1]) begin
                opcode = 3'b010; //soma
            end
        FINISH: done = 1;
    endcase
        
end

always @(*) begin //transaction logic
    next_state = state;
    case (state) 
        IDLE:
            if(start) begin
                next_state = OPERAND_SANITIZE;
            end
        OPERAND_SANITIZE: 
            if(!invalid_operation) begin
                next_state = LOAD_OPERANDS;
            end
        LOAD_OPERANDS:  next_state = SHIFT_AQ;
        SHIFT_AQ:       next_state = A_MODIFY;
        A_MODIFY:       next_state = Q_BIT_FLIP;
        Q_BIT_FLIP:     next_state = N_SUBTRATION;
        N_SUBTRATION:   next_state = N_VERIFICATION;
        N_VERIFICATION: next_state = (n==0) ? A_CORRECTION : SHIFT_AQ;
        A_CORRECTION :  next_state = FINISH;
        FINISH:         next_state = IDLE;
    endcase
end

endmodule