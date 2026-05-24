module sistema_interconexao4x4 (
    input  wire        clk,
    input  wire        rst,
    input  wire        load0, load1, load2, load3,
    input  wire [7:0]  in_dado0, in_dado1, in_dado2, in_dado3,
    output wire [7:0]  out0, out1, out2, out3
);
    wire [7:0] buf0_in, buf1_in, buf2_in, buf3_in;
    wire [7:0] buf0_out, buf1_out, buf2_out, buf3_out;
	wire [1:0] sel0, sel1, sel2, sel3;
    wire       req0, req1, req2, req3;
    wire       grant0, grant1, grant2, grant3;
    wire       clear0, clear1, clear2, clear3;

    // Instancia os buffers de entrada
    buffer_in entrada0(clk, rst, load0, in_dado0, clear0, req0, buf0_in);
    buffer_in entrada1(clk, rst, load1, in_dado1, clear1, req1, buf1_in);
    buffer_in entrada2(clk, rst, load2, in_dado2, clear2, req2, buf2_in);
    buffer_in entrada3(clk, rst, load3, in_dado3, clear3, req3, buf3_in);

    // Árbitro com prioridade fixa
    arbitro_prioridade_fixa arbitro(
        .clk(clk), .rst(rst),
        .add0(buf0_in[7:6]), .add1(buf1_in[7:6]), .add2(buf2_in[7:6]), .add3(buf3_in[7:6]),
        .req0(req0), .req1(req1), .req2(req2), .req3(req3),
        .grant0(grant0), .grant1(grant1), .grant2(grant2), .grant3(grant3),
        .sel0(sel0), .sel1(sel1), .sel2(sel2), .sel3(sel3),
		.clear0(clear0), .clear1(clear1), .clear2(clear2), .clear3(clear3)
    );

    // Rede de interconexão
    crossbar_4x4 rede (
        .in0(buf0_in), .in1(buf1_in), .in2(buf2_in), .in3(buf3_in),
        .sel0(sel0), .sel1(sel1), .sel2(sel2), .sel3(sel3), 
        .out0(buf0_out), .out1(buf1_out), .out2(buf2_out), .out3(buf3_out)
    );

    // Registradores de Saida
    buffer_out saida0(clk, rst, grant0, buf0_out, out0);
    buffer_out saida1(clk, rst, grant1, buf1_out, out1);
    buffer_out saida2(clk, rst, grant2, buf2_out, out2);
    buffer_out saida3(clk, rst, grant3, buf3_out, out3);
endmodule
