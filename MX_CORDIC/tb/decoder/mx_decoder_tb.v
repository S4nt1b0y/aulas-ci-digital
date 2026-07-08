`timescale 1ns/1ps

module mx_decoder_tb;
    reg  [31:0] elems_in;
    reg  [7:0]  scale_in;
    wire signed [31:0] out0_int;
    wire signed [31:0] out1_int;
    wire signed [31:0] out2_int;
    wire signed [31:0] out3_int;
    wire               any_nan;

    integer input_fd;
    integer output_fd;
    integer read_status;
    integer parsed_fields;
    integer line_number;
    reg [8*1024-1:0] input_path;
    reg [8*1024-1:0] output_path;
    reg [8*1024-1:0] line;
    reg [8*1024-1:0] extra_field;

    mx_decoder dut (
        .elems_in(elems_in),
        .scale_in(scale_in),
        .out0_int(out0_int),
        .out1_int(out1_int),
        .out2_int(out2_int),
        .out3_int(out3_int),
        .any_nan(any_nan)
    );

    initial begin
        elems_in = 32'd0;
        scale_in = 8'd0;
        line_number = 0;

        if (!$value$plusargs("INPUT=%s", input_path))
            $fatal(1, "Use +INPUT=<arquivo de entrada>");
        if (!$value$plusargs("OUTPUT=%s", output_path))
            $fatal(1, "Use +OUTPUT=<arquivo de saida>");

        input_fd = $fopen(input_path, "r");
        if (input_fd == 0)
            $fatal(1, "Nao foi possivel abrir a entrada: %0s", input_path);

        output_fd = $fopen(output_path, "w");
        if (output_fd == 0)
            $fatal(1, "Nao foi possivel abrir a saida: %0s", output_path);

        while (!$feof(input_fd)) begin
            line = 0;
            read_status = $fgets(line, input_fd);
            if (read_status != 0) begin
                line_number = line_number + 1;
                extra_field = 0;
                parsed_fields = $sscanf(line, "%h %h %s",
                                        elems_in, scale_in, extra_field);

                // Linhas vazias sao ignoradas, como no modelo Python.
                if (parsed_fields == 0) begin
                    // Nada a fazer.
                end else if (parsed_fields != 2) begin
                    $fatal(1, "Entrada invalida na linha %0d", line_number);
                end else begin
                    #1;
                    $fdisplay(output_fd, "%0d %0d %0d %0d %0d",
                              out0_int, out1_int, out2_int, out3_int, any_nan);
                end
            end
        end

        $fclose(input_fd);
        $fclose(output_fd);
        $finish;
    end
endmodule
