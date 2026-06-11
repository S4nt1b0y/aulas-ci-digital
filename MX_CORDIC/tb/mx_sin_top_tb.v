`timescale 1ns/1ps

module mx_sin_top_tb;
    reg  [31:0] elems_in;
    reg  [7:0]  scale_in;
    wire [31:0] elems_out;
    wire [7:0]  scale_out;
    wire        any_nan;
    wire        overflow;

    integer errors;

    mx_loopback_top dut (
        .elems_in(elems_in),
        .scale_in(scale_in),
        .elems_out(elems_out),
        .scale_out(scale_out),
        .any_nan(any_nan),
        .overflow(overflow)
    );

    task run_loopback_case;
        input [8*32-1:0] name;
        input [31:0]     elems;
        input [7:0]      scale;
        begin
            elems_in = elems;
            scale_in = scale;
            #1;

            $display("CASE %-32s IN scale=0x%02h elems=0x%08h | OUT scale=0x%02h elems=0x%08h any_nan=%0b overflow=%0b",
                     name, scale_in, elems_in, scale_out, elems_out, any_nan, overflow);

            if (any_nan || overflow || scale_out !== scale_in || elems_out !== elems_in) begin
                $display("ERROR %-31s expected scale=0x%02h elems=0x%08h",
                         name, scale_in, elems_in);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        errors = 0;
        elems_in = 32'd0;
        scale_in = 8'd0;

        run_loopback_case("zeros",             32'h00000000, 8'd127);
        run_loopback_case("all +1.0",          32'h3c3c3c3c, 8'd127);
        run_loopback_case("all -1.0",          32'hbcbcbcbc, 8'd127);
        run_loopback_case("mixed signs",       32'hbc3cbc3c, 8'd127);
        run_loopback_case("scale 2^-1",        32'h3c3c3c3c, 8'd126);
        run_loopback_case("scale 2^1",         32'h3c3c3c3c, 8'd128);
        run_loopback_case("mantissas",         32'h3f3e3d3c, 8'd127);

        if (errors == 0)
            $display("PASS: decoder -> encoder loopback preserved all canonical MX inputs.");
        else
            $display("FAIL: %0d loopback mismatch(es).", errors);

        $finish;
    end
endmodule
