module fifo (

    input wire       clk,
    input wire       rst,
    input wire       push_i,     
    input wire       pop_i,      
    input wire [7:0] data_in,     
    output reg [7:0] data_out,     
    output wire      empty,  
    output wire      full, 
    output reg       error   

);

reg [7:0] mem [0:15];
reg [3:0] wr_ptr;
reg [3:0] rd_ptr;
reg [4:0] count;

assign empty = (count == 0);
assign full  = (count == 16);

always @(posedge clk or posedge rst) begin
    if(rst) begin
        wr_ptr  <= 0;
        rd_ptr  <= 0;
        count   <= 0;
        data_out <= 0;
        error <= 0;
    end

    else begin
        error <= 0;
        if(push_i) begin
            if(full) begin
                error <= 1;
            end
            else begin
                mem[wr_ptr] <= data_in; 
                wr_ptr <= wr_ptr + 1;
                count <= count + 1;
            end
        end
        
        if(pop_i) begin
            if(empty) begin
                error <= 1;
            end
            else begin
                data_out <= mem[rd_ptr];
                rd_ptr <= rd_ptr + 1;
                count <= count - 1;
            end
        end

    end
end

endmodule