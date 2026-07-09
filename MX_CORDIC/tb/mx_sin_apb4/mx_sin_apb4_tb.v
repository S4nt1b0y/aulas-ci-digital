`timescale 1ns/1ps

module mx_sin_apb4_tb;
    localparam [10:0] ADDR_CTRL      = 11'h000;
    localparam [10:0] ADDR_STATUS    = 11'h004;
    localparam [10:0] ADDR_ELEMS_IN  = 11'h008;
    localparam [10:0] ADDR_SCALE_IN  = 11'h00c;
    localparam [10:0] ADDR_ELEMS_OUT = 11'h010;
    localparam [10:0] ADDR_SCALE_OUT = 11'h014;
    localparam [10:0] ADDR_INVALID   = 11'h018;

    reg         clk;
    reg         rst_n;
    reg         psel;
    reg         penable;
    reg         pwrite;
    reg [10:0]  paddr;
    reg [31:0]  pwdata;
    wire [31:0] prdata;
    wire        pready;
    wire        pslverr;

    reg  [31:0] ref_elems_in;
    reg  [7:0]  ref_scale_in;
    reg         ref_start;
    wire [31:0] ref_elems_out;
    wire [7:0]  ref_scale_out;
    wire        ref_any_nan;
    wire        ref_overflow;
    wire        ref_busy;
    wire        ref_done;

    integer errors;
    reg [31:0] rd_data;

    mx_sin_apb4_top dut (
        .clk(clk),
        .rst_n(rst_n),
        .psel(psel),
        .penable(penable),
        .pwrite(pwrite),
        .paddr(paddr),
        .pwdata(pwdata),
        .prdata(prdata),
        .pready(pready),
        .pslverr(pslverr)
    );

    mx_sin ref_model (
        .clk(clk),
        .rst_n(rst_n),
        .start(ref_start),
        .elems_in(ref_elems_in),
        .scale_in(ref_scale_in),
        .elems_out(ref_elems_out),
        .scale_out(ref_scale_out),
        .any_nan(ref_any_nan),
        .overflow(ref_overflow),
        .busy(ref_busy),
        .done(ref_done)
    );

    always #5 clk = ~clk;

    task check_equal32;
        input [8*64-1:0] name;
        input [31:0]     actual;
        input [31:0]     expected;
        begin
            if (actual !== expected) begin
                $display("ERROR %-64s actual=0x%08h expected=0x%08h",
                         name, actual, expected);
                errors = errors + 1;
            end
        end
    endtask

    task apb_write;
        input [10:0] addr;
        input [31:0] data;
        input        expect_err;
        begin
            @(negedge clk);
            paddr   = addr;
            pwdata  = data;
            pwrite  = 1'b1;
            psel    = 1'b1;
            penable = 1'b0;

            @(negedge clk);
            penable = 1'b1;

            @(posedge clk);
            #1;
            if (!pready) begin
                $display("ERROR APB write timeout addr=0x%03h", addr);
                errors = errors + 1;
            end
            if (pslverr !== expect_err) begin
                $display("ERROR APB write err addr=0x%03h actual=%0b expected=%0b",
                         addr, pslverr, expect_err);
                errors = errors + 1;
            end

            @(negedge clk);
            psel    = 1'b0;
            penable = 1'b0;
            pwrite  = 1'b0;
            paddr   = 11'd0;
            pwdata  = 32'd0;
        end
    endtask

    task apb_read;
        input  [10:0] addr;
        output [31:0] data;
        input         expect_err;
        begin
            @(negedge clk);
            paddr   = addr;
            pwdata  = 32'd0;
            pwrite  = 1'b0;
            psel    = 1'b1;
            penable = 1'b0;

            @(negedge clk);
            penable = 1'b1;

            @(posedge clk);
            #1;
            data = prdata;
            if (!pready) begin
                $display("ERROR APB read timeout addr=0x%03h", addr);
                errors = errors + 1;
            end
            if (pslverr !== expect_err) begin
                $display("ERROR APB read err addr=0x%03h actual=%0b expected=%0b",
                         addr, pslverr, expect_err);
                errors = errors + 1;
            end

            @(negedge clk);
            psel    = 1'b0;
            penable = 1'b0;
            paddr   = 11'd0;
        end
    endtask

    task wait_done;
        integer polls;
        begin
            polls = 0;
            rd_data = 32'd0;
            while (!rd_data[1] && polls < 8) begin
                apb_read(ADDR_STATUS, rd_data, 1'b0);
                polls = polls + 1;
            end

            if (!rd_data[1]) begin
                $display("ERROR done nao subiu dentro do limite de polls");
                errors = errors + 1;
            end
        end
    endtask

    task run_case;
        input [8*64-1:0] name;
        input [31:0]     elems;
        input [7:0]      scale;
        begin
            ref_elems_in = elems;
            ref_scale_in = scale;

            @(negedge clk);
            ref_start = 1'b1;
            @(negedge clk);
            ref_start = 1'b0;
            wait (ref_done);
            #1;

            apb_write(ADDR_ELEMS_IN, elems, 1'b0);
            apb_write(ADDR_SCALE_IN, {24'd0, scale}, 1'b0);
            apb_write(ADDR_CTRL, 32'h00000001, 1'b0);

            apb_read(ADDR_STATUS, rd_data, 1'b0);
            if (rd_data[1:0] !== 2'b01 && rd_data[1:0] !== 2'b10) begin
                $display("ERROR %-64s status inesperado apos start: 0x%08h",
                         name, rd_data);
                errors = errors + 1;
            end

            wait_done();
            check_equal32({name, " status flags"}, rd_data[3:2],
                          {30'd0, ref_overflow, ref_any_nan});

            apb_read(ADDR_ELEMS_OUT, rd_data, 1'b0);
            check_equal32({name, " elems_out"}, rd_data, ref_elems_out);

            apb_read(ADDR_SCALE_OUT, rd_data, 1'b0);
            check_equal32({name, " scale_out"}, rd_data, {24'd0, ref_scale_out});

            apb_read(ADDR_STATUS, rd_data, 1'b0);
            if (rd_data[1] !== 1'b1) begin
                $display("ERROR %-64s done deveria permanecer latched", name);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        psel = 1'b0;
        penable = 1'b0;
        pwrite = 1'b0;
        paddr = 11'd0;
        pwdata = 32'd0;
        ref_elems_in = 32'd0;
        ref_scale_in = 8'd0;
        ref_start = 1'b0;
        errors = 0;

        repeat (4) @(posedge clk);
        rst_n = 1'b1;
        repeat (2) @(posedge clk);

        apb_read(ADDR_STATUS, rd_data, 1'b0);
        check_equal32("reset status", rd_data, 32'd0);

        run_case("zeros",       32'h00000000, 8'd127);
        run_case("all +1.0",    32'h3c3c3c3c, 8'd127);
        run_case("mixed signs", 32'hbc3cbc3c, 8'd127);
        run_case("any nan",     32'h7c000000, 8'd127);

        apb_write(ADDR_CTRL, 32'h00000002, 1'b0);
        apb_read(ADDR_STATUS, rd_data, 1'b0);
        if (rd_data[1] !== 1'b0) begin
            $display("ERROR clear done nao limpou STATUS.done: 0x%08h", rd_data);
            errors = errors + 1;
        end

        apb_read(ADDR_INVALID, rd_data, 1'b1);
        check_equal32("invalid read data", rd_data, 32'd0);
        apb_write(ADDR_INVALID, 32'hdeadbeef, 1'b1);

        if (errors == 0)
            $display("PASS: mx_sin_apb4_top respondeu ao fluxo APB4 e bateu com mx_sin.");
        else
            $display("FAIL: %0d erro(s) encontrados no mx_sin_apb4_top.", errors);

        $finish;
    end
endmodule
