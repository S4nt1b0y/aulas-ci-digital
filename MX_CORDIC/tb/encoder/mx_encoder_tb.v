`timescale 1ns/1ps

module mx_encoder_tb;
    reg signed [15:0] in0_int;
    reg signed [15:0] in1_int;
    reg signed [15:0] in2_int;
    reg signed [15:0] in3_int;
    wire       [31:0] elems_out;
    wire       [7:0]  scale_out;
    wire              overflow;

    integer input_fd;
    integer output_fd;
    integer read_status;
    integer parsed_fields;
    integer line_number;
    reg [31:0] raw0, raw1, raw2, raw3;
    reg [8*1024-1:0] input_path;
    reg [8*1024-1:0] output_path;
    reg [8*1024-1:0] line;
    reg [8*1024-1:0] extra_field;

    mx_encoder dut (
        .in0_int(in0_int),
        .in1_int(in1_int),
        .in2_int(in2_int),
        .in3_int(in3_int),
        .elems_out(elems_out),
        .scale_out(scale_out),
        .overflow(overflow)
    );

    initial begin
        in0_int = 16'sd0;
        in1_int = 16'sd0;
        in2_int = 16'sd0;
        in3_int = 16'sd0;
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
                parsed_fields = $sscanf(line, "%h %h %h %h %s",
                                        raw0, raw1, raw2, raw3, extra_field);
                if (parsed_fields == 0) begin
                    // Linhas vazias sao ignoradas.
                end else if (parsed_fields != 4) begin
                    $fatal(1, "Entrada invalida na linha %0d", line_number);
                end else if (raw0 > 32'hffff || raw1 > 32'hffff ||
                             raw2 > 32'hffff || raw3 > 32'hffff) begin
                    $fatal(1, "Valor excede 16 bits na linha %0d", line_number);
                end else begin
                    in0_int = raw0[15:0];
                    in1_int = raw1[15:0];
                    in2_int = raw2[15:0];
                    in3_int = raw3[15:0];
                    #1;
                    $fdisplay(output_fd, "%08X %02X %0d",
                              elems_out, scale_out, overflow);
                end
            end
        end

        $fclose(input_fd);
        $fclose(output_fd);
        $finish;
    end
endmodule
