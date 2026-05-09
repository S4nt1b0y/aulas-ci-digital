module ram_dual (
    input  wire        clk,
    input  wire        we_a,
    input  wire        cs,
    input  wire [5:0]  addr_wr_a,
    input  wire [7:0]  data_wr_a,
    input  wire [5:0]  addr_rd_b,
    output reg  [7:0]  data_rd_a,
    output reg  [7:0]  data_rd_b
);

    reg [7:0] ram [0:63];

    always @(posedge clk) begin
        if(cs) begin 
            if (we_a) begin
                ram[addr_wr_a] <= addr_wr_a;
            end else begin 
                data_rd_a <= ram[addr_wr_a];
            end

            data_rd_b <= ram[addr_rd_b];
        end
    end

    initial begin
        $readme("mem_dados.txt",ram);
    end

endmodule