module ram_single (
    input  wire         clk,
    input  wire         cs,
    input  wire         we,
    input  wire [4:0]   addr,
    input  wire [15:0]  data_in,
    output reg  [15:0]  data_out
);

    reg [15:0] ram [0:31];

    always @(posedge clk) begin
        if(cs) begin 
            if (we) begin
                ram[addr] <= data_in;
                data_out  <= data_in;
            end

            else begin
                data_out <= ram[addr];
            end
        end
    end

endmodule