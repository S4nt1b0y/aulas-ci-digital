`timescale 1ns/1ps

module pattern_detector_tb;

localparam N          = 8;
localparam DATA_WIDTH = 16;
localparam NLOG2      = $clog2(N);
localparam ACC_WIDTH  = (2*DATA_WIDTH)+NLOG2;

reg clk;
reg rst_n;

reg  signed [DATA_WIDTH-1:0] in_data;
reg                          in_valid;
wire                         in_ready;

wire [NLOG2-1:0]             rom_addr;
reg  signed [DATA_WIDTH-1:0] rom_data;

wire signed [ACC_WIDTH-1:0]  out_data;
wire                         out_valid;
reg                          out_ready;

reg signed [DATA_WIDTH-1:0] coeff [0:N-1];

integer sample_file;
integer result_file;
integer status;

integer sample_value;
integer sample_idx;
integer corr_idx;

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

///////////////////////////////////////////////////////////////////////////////
// Clock
///////////////////////////////////////////////////////////////////////////////

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

///////////////////////////////////////////////////////////////////////////////
// ROM de coeficientes
///////////////////////////////////////////////////////////////////////////////

initial begin
    $readmemh("reference.mem", coeff);

    $display("Coeficientes carregados:");
    for (sample_idx = 0; sample_idx < N; sample_idx = sample_idx + 1)
        $display("h[%0d] = %0d", sample_idx, coeff[sample_idx]);
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        rom_data <= 0;
    else
        rom_data <= coeff[rom_addr];
end

///////////////////////////////////////////////////////////////////////////////
// Captura resultados
///////////////////////////////////////////////////////////////////////////////

always @(posedge clk) begin
    if (rst_n && out_valid && out_ready) begin

        $display(
            "corr_idx=%0d  out_data=%0d",
            corr_idx,
            out_data
        );

        $fwrite(
            result_file,
            "%0d %0d\n",
            corr_idx,
            out_data
        );

        corr_idx <= corr_idx + 1;
    end
end

///////////////////////////////////////////////////////////////////////////////
// Envio de amostras
///////////////////////////////////////////////////////////////////////////////

task send_sample;
    input signed [15:0] sample;
begin

    @(posedge clk);

    in_data  <= sample;
    in_valid <= 1'b1;

    while (!(in_valid && in_ready))
        @(posedge clk);

    @(posedge clk);

    in_valid <= 1'b0;

end
endtask

///////////////////////////////////////////////////////////////////////////////
// Teste principal
///////////////////////////////////////////////////////////////////////////////

initial begin

    rst_n      = 1'b0;
    in_valid   = 1'b0;
    in_data    = 0;
    out_ready  = 1'b1;

    sample_idx = 0;
    corr_idx   = 0;

    repeat(5) @(posedge clk);

    rst_n = 1'b1;

    ///////////////////////////////////////////////////////////////////////
    // Arquivos
    ///////////////////////////////////////////////////////////////////////

    sample_file = $fopen("samples.txt", "r");

    if (sample_file == 0) begin
        $display("ERRO: nao foi possivel abrir samples.txt");
        $finish;
    end

    result_file = $fopen("correlation.txt", "w");

    ///////////////////////////////////////////////////////////////////////
    // Alimenta o DUT
    ///////////////////////////////////////////////////////////////////////

    while (!$feof(sample_file)) begin

        status = $fscanf(
            sample_file,
            "%d\n",
            sample_value
        );

        if (status == 1) begin

            send_sample(sample_value);

            sample_idx = sample_idx + 1;

        end
    end

    ///////////////////////////////////////////////////////////////////////
    // Espera esvaziar pipeline
    ///////////////////////////////////////////////////////////////////////

    repeat(100) @(posedge clk);

    $fclose(sample_file);
    $fclose(result_file);

    $display("Fim da simulacao");
    $finish;

end

endmodule