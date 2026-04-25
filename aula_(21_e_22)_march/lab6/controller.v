module controller (
    input wire      zero,
    input wire[2:0] phase,
    input wire[2:0] opcode,
    output reg sel,
    output reg rd,
    output reg ld_ir,
    output reg halt,
    output reg inc_pc,
    output reg ld_ac,
    output reg ld_pc,
    output reg wr,
    output reg data_e
);

wire alu_op = ((opcode == 3'b010)| (opcode == 3'b011) | (opcode == 3'b100) | (opcode == 3'b101));

always @(*) begin
    sel     = 1'b0;
    rd      = 1'b0;
    ld_ir   = 1'b0;
    halt    = 1'b0;
    inc_pc  = 1'b0;
    ld_ac   = 1'b0;
    ld_pc   = 1'b0;
    wr      = 1'b0;
    data_e  = 1'b0;

    case(phase)
    3'd0: sel = 1'b1; //INST_ADDR
    3'd1: begin       //INST_FETCH
        sel = 1'b1;
        rd  = 1'b1;
    end
    3'd2: begin     //INST_LOAD
        sel     = 1'b1;
        rd      = 1'b1;
        ld_ir   = 1'b1;
    end             
    3'd3: begin     //IDLE
        sel     = 1'b1;
        rd      = 1'b1;
        ld_ir   = 1'b1;
    end 
    3'd4: begin     //OP_ADDR
        halt    = (opcode == 3'b000);
        inc_pc  = 1'b1;
    end       

    3'd5: begin     //OP_FETCH
        rd      = alu_op;
    end    
    3'd6: begin     //ALU_OP
        rd      = alu_op;
        inc_pc  = (zero && (opcode == 3'b001));
        ld_pc   = (opcode == 3'b111);
        data_e  = (opcode == 3'b110);
    end  
    3'd7: begin     //STORE
        rd      = alu_op;
        ld_ac   = alu_op;
        ld_pc   = (opcode == 3'b111);
        wr      = (opcode == 3'b110);
        data_e  = (opcode == 3'b110);
    end  

    endcase
end
endmodule