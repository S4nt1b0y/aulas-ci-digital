`timescale 1ns/1ps

module pattern_detector_tb;

localparam N = 8;
localparam DATA_WIDTH = 16;
localparam NLOG2 = $clog2(N);
localparam ACC_WIDTH = (2 * DATA_WIDTH) + NLOG2;

reg clk;
reg rst_n;
reg signed [DATA_WIDTH-1:0] in_data;
reg in_valid;
wire in_ready;
wire [NLOG2-1:0] rom_addr;
reg signed [DATA_WIDTH-1:0] rom_data;
wire signed [ACC_WIDTH-1:0] out_data;
wire out_valid;
reg out_ready;

reg signed [DATA_WIDTH-1:0] coeff [0:N-1];
reg signed [DATA_WIDTH-1:0] window [0:N-1];
integer accepted_count;
integer errors;
integer i;

pattern_detector #(
    .N(N),
    .DATA_WIDTH(DATA_WIDTH),
    .NLOG2(NLOG2),
    .ACC_WIDTH(ACC_WIDTH)
) dut (
    .clk(clk),
    .rst_n(rst_n),
    .in_data(in_data),
    .in_valid(in_valid),
    .in_ready(in_ready),
    .rom_addr(rom_addr),
    .rom_data(rom_data),
    .out_data(out_data),
    .out_valid(out_valid),
    .out_ready(out_ready)
);

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

initial begin
    coeff[0] =  16'sd12000;
    coeff[1] = -16'sd8000;
    coeff[2] =  16'sd16000;
    coeff[3] =  16'sd4000;
    coeff[4] = -16'sd14000;
    coeff[5] =  16'sd10000;
    coeff[6] = -16'sd6000;
    coeff[7] =  16'sd14000;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rom_data <= {DATA_WIDTH{1'b0}};
    end else begin
        rom_data <= coeff[rom_addr];
    end
end

function signed [ACC_WIDTH-1:0] expected_corr;
    integer k;
    reg signed [ACC_WIDTH-1:0] acc;
    begin
        acc = {ACC_WIDTH{1'b0}};
        for (k = 0; k < N; k = k + 1) begin
            acc = acc + (window[k] * coeff[k]);
        end
        expected_corr = acc;
    end
endfunction

task shift_window;
    input signed [DATA_WIDTH-1:0] sample;
    integer k;
    begin
        for (k = N-1; k > 0; k = k - 1) begin
            window[k] = window[k-1];
        end
        window[0] = sample;
    end
endtask

task send_sample;
    input signed [DATA_WIDTH-1:0] sample;
    begin
        @(negedge clk);
        in_data = sample;
        in_valid = 1'b1;

        while (!in_ready) begin
            @(negedge clk);
        end

        @(negedge clk);
        in_valid = 1'b0;
        shift_window(sample);
        accepted_count = accepted_count + 1;

        if (accepted_count < N && out_valid) begin
            $display("ERRO: out_valid ativo antes de preencher N amostras");
            errors = errors + 1;
        end
    end
endtask

task wait_and_check_result;
    input signed [ACC_WIDTH-1:0] expected;
    reg signed [ACC_WIDTH-1:0] held_data;
    integer cycles;
    begin
        cycles = 0;
        while (!out_valid && cycles < 40) begin
            if (in_ready) begin
                $display("ERRO: in_ready ativo durante processamento");
                errors = errors + 1;
            end
            @(negedge clk);
            cycles = cycles + 1;
        end

        if (!out_valid) begin
            $display("ERRO: timeout esperando out_valid");
            errors = errors + 1;
        end else begin
            held_data = out_data;
            if (out_data !== expected) begin
                $display("ERRO: out_data=%0d esperado=%0d", out_data, expected);
                errors = errors + 1;
            end

            out_ready = 1'b0;
            repeat (3) begin
                @(negedge clk);
                if (!out_valid || out_data !== held_data || in_ready) begin
                    $display("ERRO: saida nao permaneceu estavel com out_ready=0");
                    errors = errors + 1;
                end
            end

            out_ready = 1'b1;
            @(negedge clk);
            if (out_valid) begin
                $display("ERRO: out_valid nao baixou apos handshake de saida");
                errors = errors + 1;
            end
        end
    end
endtask

initial begin
    rst_n = 1'b0;
    in_data = {DATA_WIDTH{1'b0}};
    in_valid = 1'b0;
    out_ready = 1'b1;
    accepted_count = 0;
    errors = 0;

    for (i = 0; i < N; i = i + 1) begin
        window[i] = {DATA_WIDTH{1'b0}};
    end

    repeat (3) @(negedge clk);
    rst_n = 1'b1;

    send_sample(16'sd1);
    send_sample(-16'sd2);
    send_sample(16'sd3);
    send_sample(16'sd4);
    send_sample(-16'sd5);
    send_sample(16'sd6);
    send_sample(16'sd7);
    send_sample(-16'sd8);
    wait_and_check_result(expected_corr());

    send_sample(16'sd9);
    wait_and_check_result(expected_corr());

    if (errors == 0) begin
        $display("TESTE OK");
    end else begin
        $display("TESTE FALHOU: %0d erro(s)", errors);
    end

    $finish;
end

endmodule
