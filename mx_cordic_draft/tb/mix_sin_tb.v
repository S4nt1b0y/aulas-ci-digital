`timescale 1ns/1ps

module mx_sin_tb;

    reg         clk;
    reg         rst;
    reg         start;
    reg         op_mode;
    reg [31:0]  in_elems;
    reg [7:0]   in_scale;

    wire        busy;
    wire        done;
    wire        input_valid;
    wire        output_valid;
    wire        error_overflow;
    wire [31:0] out_elems;
    wire [7:0]  out_scale;

    //-----------------------------------------
    // DUT
    //-----------------------------------------
    mx_sin dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .op_mode(op_mode),
        .in_elems(in_elems),
        .in_scale(in_scale),

        .busy(busy),
        .done(done),
        .input_valid(input_valid),
        .output_valid(output_valid),
        .error_overflow(error_overflow),

        .out_elems(out_elems),
        .out_scale(out_scale)
    );

    //-----------------------------------------
    // Clock 100 MHz
    //-----------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //-----------------------------------------
    // Task de teste
    //-----------------------------------------
    task test_vector;
        input [31:0] elems;
        input [7:0]  scale;
        begin

            @(posedge clk);
            in_elems <= elems;
            in_scale <= scale;

            // Espera pipeline
            @(posedge clk);
            @(posedge clk);

            if (out_elems !== elems) begin
                $display("ERRO ELEMS");
                $display("Esperado = %h", elems);
                $display("Obtido   = %h", out_elems);
            end
            else begin
                $display("ELEMS OK : %h", elems);
            end

            if (out_scale !== scale) begin
                $display("ERRO SCALE");
                $display("Esperado = %h", scale);
                $display("Obtido   = %h", out_scale);
            end
            else begin
                $display("SCALE OK : %h", scale);
            end

        end
    endtask

    //-----------------------------------------
    // Estímulos
    //-----------------------------------------
    initial begin

        rst      = 1;
        start    = 0;
        op_mode  = 0;
        in_elems = 0;
        in_scale = 0;

        repeat(5) @(posedge clk);

        rst = 0;

        // Alguns exemplos

        test_vector(32'h00000000, 8'h00);

        test_vector(32'h01020304, 8'h10);

        test_vector(32'h7F7F7F7F, 8'h7F);

        test_vector(32'h80808080, 8'h80);

        test_vector(32'h12345678, 8'h55);

        test_vector(32'hFFFFFFFF, 8'hFE);

        #100;

        $display("Fim da simulacao");
        $finish;
    end

endmodule