primitive flipflop_udp(y, rst, clk, d);
    input d, clk, rst;
    output y;

    reg y;

table
    // rst  clk   d   : state : next_state
    
    // --- Lógica de Reset Assíncrono ---
       (01)  ?    ?   :   ?   :  0 ; // Borda de subida no Reset
       (x1)  ?    ?   :   ?   :  0 ; // Borda de subida no Reset
        1    ?    ?   :   ?   :  0 ; // Borda de subida no Reset

    // --- Lógica de Clock (Borda de Subida) ---
        0   (01)  0   :   ?   :  0 ; // Clock subindo, D=0 -> 0
        0   (01)  1   :   ?   :  1 ; // Clock subindo, D=1 -> 1
        0   (x1)  0   :   ?   :  0 ; // Redundância para X
        0   (x1)  1   :   ?   :  1 ;

    // --- Manutenção de Estado (Bordas de Descida ou Estável) ---
        0   (10)  ?   :   ?   :  - ; // Borda de descida do clock: mantém
       (10)  ?    ?   :   ?   :  - ; // Borda de descida do Reset: mantém
        1    ?   (??) :   ?   :  - ; // Borda de descida do Reset: mantém
    
endtable

endprimitive