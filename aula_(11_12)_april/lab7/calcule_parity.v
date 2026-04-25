module calcule_parity (
    input [3:0] a,
    output res
);
    
    function get_parity;
        input [3:0] a; begin
        get_parity = ^a;
        end
    endfunction

    assign res = get_parity(a);

endmodule