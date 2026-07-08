`timescale 1ns/1ps

module seno_tb;
    reg signed [31:0] angle0;

    wire [5:0] lut_index0;
    wire       negate0;
    wire signed [31:0] lut_value0;
    wire signed [31:0] sine0;

    integer input_fd;
    integer output_fd;
    integer read_status;
    integer parsed_fields;
    integer line_number;
    reg [8*1024-1:0] input_path;
    reg [8*1024-1:0] output_path;
    reg [8*1024-1:0] line;
    reg [8*1024-1:0] extra_field;

    phase_preprocess preprocess_dut (
        .angle0(angle0),
        .angle1(32'sd0),
        .angle2(32'sd0),
        .angle3(32'sd0),
        .lut_index0(lut_index0),
        .lut_index1(),
        .lut_index2(),
        .lut_index3(),
        .negate0(negate0),
        .negate1(),
        .negate2(),
        .negate3()
    );

    LUT_Seno lut_dut (
        .index0(lut_index0),
        .index1(6'd0),
        .index2(6'd0),
        .index3(6'd0),
        .sin_value0(lut_value0),
        .sin_value1(),
        .sin_value2(),
        .sin_value3()
    );

    phase_postprocess postprocess_dut (
        .lut0(lut_value0),
        .lut1(32'sd0),
        .lut2(32'sd0),
        .lut3(32'sd0),
        .negate0(negate0),
        .negate1(1'b0),
        .negate2(1'b0),
        .negate3(1'b0),
        .out0(sine0),
        .out1(),
        .out2(),
        .out3()
    );

    initial begin
        angle0 = 32'sd0;
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
                parsed_fields = $sscanf(line, "%h %s", angle0, extra_field);

                if (parsed_fields == 0) begin
                    // Linhas vazias sao ignoradas, como no modelo Python.
                end else if (parsed_fields != 1) begin
                    $fatal(1, "Entrada invalida na linha %0d", line_number);
                end else begin
                    #1;
                    $fdisplay(output_fd, "%0d", sine0);
                end
            end
        end

        $fclose(input_fd);
        $fclose(output_fd);
        $finish;
    end
endmodule
