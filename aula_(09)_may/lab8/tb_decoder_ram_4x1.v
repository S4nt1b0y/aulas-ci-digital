`timescale 1ns/1ps

module tb_decoder_ram_4x1;
reg clk;
reg we;
reg [15:0] addr;
reg [7:0] din;
wire [7:0] dout0;
wire [7:0] dout1;
wire [7:0] dout2;
wire [7:0] dout3;
wire [9:0] effective_addr;

wire cs0, cs1, cs2, cs3;

decoder_ram_4x1 dut (
    .addr(addr),
    .effective_addr(effective_addr),
    .cs0(cs0),
    .cs1(cs1),
    .cs2(cs2),
    .cs3(cs3)

);

// ======================================================
// MEMORIAS
// ======================================================

single_port_ram ram0 (
    .clk(clk),
    .we(we),
    .cs(cs0),
    .addr(effective_addr),
    .din(din),
    .dout(dout0)
);

single_port_ram ram1 (
    .clk(clk),
    .we(we),
    .cs(cs1),
    .addr(effective_addr),
    .din(din),
    .dout(dout1)
);

single_port_ram ram2 (
    .clk(clk),
    .we(we),
    .cs(cs2),
    .addr(effective_addr),
    .din(din),
    .dout(dout2)
);

single_port_ram ram3 (
    .clk(clk),
    .we(we),
    .cs(cs3),
    .addr(effective_addr),
    .din(din),
    .dout(dout3)
);

always #5 clk = ~clk;

initial begin

    $dumpfile("wave.vcd");
    $dumpvars(0, tb_decoder_ram_4x1);

    clk  = 0;
    we   = 0;
    addr = 0;
    din  = 0;

    $display("\n====================================");
    $display(" TESTBENCH DECODER RAM 4x1 ");
    $display("====================================\n");

    // =================================================
    // TESTE 1 - ESCRITA
    // =================================================

    $display(">>> TESTE 1 - ESCRITA");

    we = 1;

    addr = 16'h0402;
    din  = 8'hA5;
    #10;
    $display("WRITE RAM0 | ADDR=0x%h | DATA=0x%h | CS=%b%b%b%b",
              addr, din, cs3, cs2, cs1, cs0);

    addr = 16'h0810;
    din  = 8'hB6;
    #10;
    $display("WRITE RAM1 | ADDR=0x%h | DATA=0x%h | CS=%b%b%b%b",
              addr, din, cs3, cs2, cs1, cs0);

    addr = 16'h0C20;
    din  = 8'hC7;
    #10;
    $display("WRITE RAM2 | ADDR=0x%h | DATA=0x%h | CS=%b%b%b%b",
              addr, din, cs3, cs2, cs1, cs0);

    addr = 16'h1015;
    din  = 8'hD8;
    #10;
    $display("WRITE RAM3 | ADDR=0x%h | DATA=0x%h | CS=%b%b%b%b",
              addr, din, cs3, cs2, cs1, cs0);

    // =================================================
    // TESTE 2 - LEITURA
    // =================================================

    $display("\n>>> TESTE 2 - LEITURA");

    we = 0;

    addr = 16'h0402;
    #10;
    $display("READ RAM0  | ESPERADO=0xA5 | RECEBIDO=0x%h",
              dout0);

    addr = 16'h0810;
    #10;
    $display("READ RAM1  | ESPERADO=0xB6 | RECEBIDO=0x%h",
              dout1);

    addr = 16'h0C20;
    #10;
    $display("READ RAM2  | ESPERADO=0xC7 | RECEBIDO=0x%h",
              dout2);

    addr = 16'h1015;
    #10;
    $display("READ RAM3  | ESPERADO=0xD8 | RECEBIDO=0x%h",
              dout3);

    // =================================================
    // TESTE 3 - SOBRESCRITA
    // =================================================

    $display("\n>>> TESTE 3 - SOBRESCRITA");

    we = 1;

    addr = 16'h0402;
    din  = 8'h55;
    #10;

    addr = 16'h0402;
    din  = 8'h99;
    #10;

    we = 0;

    addr = 16'h0402;
    #10;

    $display("READ RAM0  | ESPERADO=0x99 | RECEBIDO=0x%h",
              dout0);

    // =================================================
    // TESTE 4 - MULTIPLOS ENDERECOS
    // =================================================

    $display("\n>>> TESTE 4 - MULTIPLOS ENDERECOS");

    we = 1;

    addr = 16'h0800; din = 8'h11; #10;
    addr = 16'h0801; din = 8'h22; #10;
    addr = 16'h0802; din = 8'h33; #10;
    addr = 16'h0803; din = 8'h44; #10;

    we = 0;

    addr = 16'h0800; #10;
    $display("ADDR=0x0800 | ESP=0x11 | REC=0x%h", dout1);

    addr = 16'h0801; #10;
    $display("ADDR=0x0801 | ESP=0x22 | REC=0x%h", dout1);

    addr = 16'h0802; #10;
    $display("ADDR=0x0802 | ESP=0x33 | REC=0x%h", dout1);

    addr = 16'h0803; #10;
    $display("ADDR=0x0803 | ESP=0x44 | REC=0x%h", dout1);

    // =================================================
    // TESTE 5 - ENDERECOS INVALIDOS
    // =================================================

    $display("\n>>> TESTE 5 - ENDERECOS INVALIDOS");

    addr = 16'h0000;
    #10;

    $display("ADDR=0x0000 | CS0=%b CS1=%b CS2=%b CS3=%b",
              cs0, cs1, cs2, cs3);

    addr = 16'hFFFF;
    #10;

    $display("ADDR=0xFFFF | CS0=%b CS1=%b CS2=%b CS3=%b",
              cs0, cs1, cs2, cs3);

    // =================================================
    // FINAL
    // =================================================

    $display("\n====================================");
    $display(" FIM DA SIMULACAO ");
    $display("====================================");

    $finish;

end

endmodule