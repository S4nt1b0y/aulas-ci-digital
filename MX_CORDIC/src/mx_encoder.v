module mx_encoder (
    input  wire signed [31:0] in0_int,
    input  wire signed [31:0] in1_int,
    input  wire signed [31:0] in2_int,
    input  wire signed [31:0] in3_int,
    output reg  [31:0] elems_out, // 4 elementos de 8 bits (E5M2)
    output reg  [7:0]  scale_out, // Escala compartilhada (E8M0)
    output reg         overflow
);

    // Função absoluta para inteiros de 32 bits
    function automatic [31:0] abs32;
        input signed [31:0] v;
        begin
            abs32 = (v < 0) ? -v : v;
        end
    endfunction

    // Função para encontrar o índice do bit mais significativo (MSB)
    function automatic integer msb_index32;
        input [31:0] v;
        integer i;
        begin
            msb_index32 = -1;
            for (i = 31; i >= 0; i = i - 1) begin
                if (v[i] && msb_index32 < 0)
                    msb_index32 = i;
            end
        end
    endfunction

    // Função para converter o valor absoluto inteiramente escalado para E5M2
    function automatic [7:0] encode_e5m2;
        input sign;
        input [31:0] abs_val;
        integer msb;
        integer exp_val;
        reg [4:0] exp;
        reg [1:0] mant;
        begin
            if (abs_val == 0) begin
                encode_e5m2 = {sign, 7'd0};
            end else begin
                msb = msb_index32(abs_val);
                
                // Como a entrada é inteira, o MSB já é o expoente real em base 2.
                // O bias do E5M2 é 15. Portanto, exp_val = expoente_real + bias.
                exp_val = msb + 15; 
                
                if (exp_val < 1) begin
                    // Tratamento de Subnormais (Truncado para zero neste estágio)
                    exp = 5'd0;
                    mant = 2'd0;
                end else if (exp_val > 30) begin // Satura para o máximo normal do E5M2
                    exp = 5'd30;
                    mant = 2'b11;
                end else begin
                    exp = exp_val[4:0];
                    // Extrai os 2 bits da mantissa logo abaixo do MSB
                    mant = (abs_val >> (msb - 2)) & 2'b11; 
                end
                
                encode_e5m2 = {sign, exp, mant};
            end
        end
    endfunction

    reg [31:0] a0, a1, a2, a3;
    reg [31:0] maxa;
    integer max_msb;
    integer scale_exp;
    integer shift_amt;
    
    reg [31:0] scaled_a0, scaled_a1, scaled_a2, scaled_a3;

    always @(*) begin
        overflow = 1'b0;
        $display("int elem0=%d, elem1=%d, elem2=%d, elem3=%d", in0_int, in1_int, in2_int, in3_int);
        // Obtém os valores absolutos das entradas inteiras
        a0 = abs32(in0_int);
        a1 = abs32(in1_int);
        a2 = abs32(in2_int);
        a3 = abs32(in3_int);

        // Encontra o maior valor absoluto do bloco de 4 elementos
        maxa = a0;
        if (a1 > maxa) maxa = a1;
        if (a2 > maxa) maxa = a2;
        if (a3 > maxa) maxa = a3;

        if (maxa == 0) begin
            scale_out = 8'd127; // Escala ativa de 1.0 (2^(127-127))
            elems_out = 32'd0;
        end else begin
            max_msb = msb_index32(maxa);
            
            // Regra da Seção 6.3 do OCP MX: e_scale = expoente_maximo_real - maior_potencia_do_elemento
            // Para o E5M2, o maior expoente normalizado é 15 (E_max = 30, Bias = 15 -> 30 - 15 = 15)
            // Como a entrada é inteira, o 'expoente_maximo_real' é o próprio 'max_msb'.
            scale_exp = max_msb - 15;

            // Limites de saturação do formato de escala E8M0 (-127 a 127)
            if (scale_exp > 127) begin 
                scale_exp = 127;
                overflow = 1'b1;
            end
            if (scale_exp < -127) begin 
                scale_exp = -127;
            end

            scale_out = scale_exp + 127; // Aplica o bias de 127 do E8M0

            if (scale_out == 8'hFF) begin // Evita o valor reservado para NaN/Inf
                scale_out = 8'hFE;
                overflow = 1'b1;
            end

            // Escalona as grandezas de volta (Divisão por 2^scale_exp)
            // Para trazer o número de maior magnitude exatamente para o teto dinâmico do E5M2 (onde MSB vira 15):
            shift_amt = 15 - max_msb;

            if (shift_amt >= 0) begin
                scaled_a0 = a0 << shift_amt;
                scaled_a1 = a1 << shift_amt;
                scaled_a2 = a2 << shift_amt;
                scaled_a3 = a3 << shift_amt;
            end else begin
                scaled_a0 = a0 >> (-shift_amt);
                scaled_a1 = a1 >> (-shift_amt);
                scaled_a2 = a2 >> (-shift_amt);
                scaled_a3 = a3 >> (-shift_amt);
            end

            // Codifica dinamicamente cada elemento em E5M2 (S, E5, M2)
            elems_out[7:0]   = encode_e5m2(in0_int[31], scaled_a0);
            elems_out[15:8]  = encode_e5m2(in1_int[31], scaled_a1);
            elems_out[23:16] = encode_e5m2(in2_int[31], scaled_a2);
            elems_out[31:24] = encode_e5m2(in3_int[31], scaled_a3);
        end
    end
endmodule