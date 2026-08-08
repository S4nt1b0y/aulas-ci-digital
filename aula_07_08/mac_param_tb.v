`timescale 1ns/1ps

module mac_param_tb;

    //============================================================
    // Configurações
    //============================================================
    localparam DW1  = 8;
    localparam NT1  = 1024;
    localparam AW1  = 2*DW1 + $clog2(NT1);

    //============================================================
    // Clock
    //============================================================
    reg clk;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //============================================================
    // DUT 1 (8 bits, 16 termos)
    //============================================================
    reg rst1, start1, valid1;
    reg [DW1-1:0] a1, b1;
    wire busy1, done1;
    wire [AW1-1:0] result1;

 

    mac_param dut (
        .clk(clk),
        .rst_n(rst1),
        .start(start1),
        .valid(valid1),
        .a(a1),
        .b(b1),
        .busy(busy1),
        .done(done1),
        .result(result1)
    );

    integer i;
    integer expected1;

    initial begin
        $sdf_annotate("delays.sdf", mac_param_tb.dut, ,"sdf.log","MAXIMUM");
    end

    //============================================================
    // Teste da configuração 1
    //============================================================
    initial begin

        rst1   = 0;
        start1 = 0;
        valid1 = 0;
        a1     = 0;
        b1     = 0;

        #20 rst1 = 1;

        @(posedge clk);
        start1 <= 1;

        @(posedge clk);
        start1 <= 0;

        expected1 = 0;

        for(i=0; i<NT1; i=i+1) begin
            @(posedge clk);
            valid1 <= 1;
            a1 <= i;
            b1 <= 2;
            expected1 = expected1 + i*2;
        end

        @(posedge clk);
        valid1 <= 0;

        wait(done1);

        if(result1 == expected1)
            $display("[PASS] DATA_WIDTH=%0d NUM_TERMS=%0d Result=%0d",
                     DW1, NT1, result1);
        else
            $display("[FAIL] DATA_WIDTH=%0d NUM_TERMS=%0d Esperado=%0d Obtido=%0d",
                     DW1, NT1, expected1, result1);
        
        #20;
        $finish;
    end
 
endmodule