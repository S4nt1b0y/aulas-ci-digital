module buffer_in(
    input  wire         clk,
    input  wire         rst,
    input  wire         load,          
    input  wire [31:0]  dado_in,
    input  wire         clear,         
    output wire         req,           
    output reg  [31:0]  dado_out
);

    reg cheio;

    assign req = cheio; //sempre que estiver cheio faz requisicao

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cheio     <= 0;
            dado_out  <= 8'b0;
        end else begin
            if (load && !cheio) begin
                dado_out <= dado_in;
                cheio    <= 1;
            end
            if (clear && cheio) begin
                cheio  <= 0;
            end 
            end
    end
endmodule
