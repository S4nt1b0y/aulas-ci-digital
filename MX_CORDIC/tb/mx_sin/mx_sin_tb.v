`timescale 1ns/1ps

module mx_sin_tb;
    reg         clk;
    reg         rst_n;
    reg         start;
    reg  [31:0] elems_in;
    reg  [7:0]  scale_in;
    wire [31:0] elems_out;
    wire [7:0]  scale_out;
    wire        any_nan;
    wire        overflow;
    wire        busy;
    wire        done;

    integer input_fd;
    integer output_fd;
    integer read_status;
    integer parsed_fields;
    integer line_number;
    reg [8*1024-1:0] input_path;
    reg [8*1024-1:0] output_path;
    reg [8*1024-1:0] line;
    reg [8*1024-1:0] extra_field;

    mx_sin dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .elems_in(elems_in),
        .scale_in(scale_in),
        .elems_out(elems_out),
        .scale_out(scale_out),
        .any_nan(any_nan),
        .overflow(overflow),
        .busy(busy),
        .done(done)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        start = 1'b0;
        elems_in = 32'd0;
        scale_in = 8'd0;
        line_number = 0;

        repeat (4) @(posedge clk);
        rst_n = 1'b1;
        repeat (2) @(posedge clk);

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

                if (parsed_fields == 0) begin
                    // Linhas vazias sao ignoradas, como no modelo Python.
                end else if (parsed_fields != 2) begin
                    $fatal(1, "Entrada invalida na linha %0d", line_number);
                end else begin
                    @(negedge clk);
                    start = 1'b1;
                    @(negedge clk);
                    start = 1'b0;
                    wait (done);
                    #1;
                    $fdisplay(output_fd, "%08x %02x %0d %0d",
                              elems_out, scale_out, any_nan, overflow);
                end
            end
        end

        $fclose(input_fd);
        $fclose(output_fd);
        $finish;
    end
endmodule
