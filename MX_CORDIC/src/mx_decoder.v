`timescale 1ns/1ps

module mx_decoder (
    input  wire [31:0] elems_in,   // 4 elementos de 8 bits (E5M2)
    input  wire [7:0]  scale_in,   // Fator de escala compartilhado (E8M0)
    output reg  signed [31:0] out0_int,
    output reg  signed [31:0] out1_int,
    output reg  signed [31:0] out2_int,
    output reg  signed [31:0] out3_int,
    output reg               any_nan
);

    // Função para decodificar E5M2 diretamente para o valor inteiro equivalente (com bias e expoente real)
    // Retorna o valor base do elemento e o expoente dele que precisará ser somado ao expoente da escala.
    task automatic decode_e5m2_base;
        input  [7:0] fp;
        output signed [31:0] value;
        output integer real_exp; // Retorna o expoente real do elemento
        reg sign;
        reg [4:0] exp;
        reg [1:0] mant;
        begin
            sign = fp[7];
            exp  = fp[6:2];
            mant = fp[1:0];

            if (exp == 5'b11111) begin
                real_exp = 999; // Flag para Infinito/NaN [cite: 185]
                value = sign ? 32'sh80000000 : 32'sh7fffffff;
            end else if (exp == 5'b00000) begin 
                // Subnormais [cite: 185]
                if (mant == 2'b00) begin
                    real_exp = 0;
                    value = 32'sd0;
                end else begin
                    // Subnormal no E5M2: formato 0.M -> mantissa tem tamanho 2.
                    // O expoente efetivo é 1 - bias = 1 - 15 = -14 [cite: 177, 185]
                    // Para tratar como inteiro, jogamos a mantissa para os bits inteiros e compensamos no expoente
                    real_exp = -14 - 2; 
                    value = sign ? -$signed({30'd0, mant}) : $signed({30'd0, mant});
                end
            end else begin                                          
                // Casos Normais [cite: 176]
                // Formato 1.M -> Adiciona o bit implícito 1 na posição da mantissa (1xx)
                // O expoente unbias seria: exp - 15[cite: 176, 185]. 
                // Como movemos a mantissa 2 casas para virar inteiro (1xx), subtraímos 2 do expoente real
                real_exp = $signed({1'b0, exp}) - 15 - 2;
                value = sign ? -$signed({29'd0, 1'b1, mant}) : $signed({29'd0, 1'b1, mant});
            end
        end
    endtask

    // Aplica a escala combinada deslocando os bits diretamente para o alvo inteiro
    function automatic signed [31:0] apply_scale_to_int;
        input signed [31:0] base_val;
        input integer total_exponent;
        reg signed [63:0] shifted;
        begin
            // Zero permanece zero para qualquer escala finita.
            if (base_val == 0) begin
                apply_scale_to_int = 32'sd0;
            end else if (total_exponent > 30) begin
                // Saturação caso mude de escala além do limite de um int32 assinado
                apply_scale_to_int = (base_val < 0) ? 32'sh80000000 : 32'sh7fffffff;
            end else if (total_exponent < -32) begin
                // Underflow absoluto
                apply_scale_to_int = 32'sd0;
            end else begin
                if (total_exponent >= 0) begin
                    shifted = $signed(base_val) <<< total_exponent;
                    // Checa saturação pós-shift
                    if (shifted > 64'sh000000007fffffff) apply_scale_to_int = 32'sh7fffffff;
                    else if (shifted < 64'shffffffff80000000) apply_scale_to_int = 32'sh80000000;
                    else apply_scale_to_int = shifted[31:0];
                end else begin
                    // Trunca valores fracionarios em direcao a zero. Um shift
                    // aritmetico direto de um negativo arredondaria para -infinito.
                    if (base_val < 0)
                        apply_scale_to_int = -((-base_val) >>> (-total_exponent));
                    else
                        apply_scale_to_int = base_val >>> (-total_exponent);
                end
            end
        end
    endfunction

    integer exp0, exp1, exp2, exp3;
    integer scale_unbias;
    integer b0, b1, b2, b3;
    

    always @(*) begin
        decode_e5m2_base(elems_in[7:0], b0, exp0);
        decode_e5m2_base(elems_in[15:8], b1, exp1);
        decode_e5m2_base(elems_in[23:16], b2, exp2);
        decode_e5m2_base(elems_in[31:24], b3, exp3);
        any_nan = 1'b0;
        
        // Despolariza o expoente da escala compartilhada (E8M0 bias é 127) 
        scale_unbias = $signed({1'b0, scale_in}) - 127;

        // Calcula as saídas aplicando o shift combinado (expoente do elemento + expoente da escala)
        out0_int = apply_scale_to_int(b0, exp0 + scale_unbias);
        out1_int = apply_scale_to_int(b1, exp1 + scale_unbias);
        out2_int = apply_scale_to_int(b2, exp2 + scale_unbias);
        out3_int = apply_scale_to_int(b3, exp3 + scale_unbias);

        // Tratamento de NaNs/Infinidades da escala ou dos elementos [cite: 147, 158, 218]
        if (scale_in == 8'hFF || exp0 == 999 || exp1 == 999 || exp2 == 999 || exp3 == 999) begin
            any_nan  = 1'b1;
            out0_int = 32'sd0;
            out1_int = 32'sd0;
            out2_int = 32'sd0;
            out3_int = 32'sd0;
        end
       // $display("int elem0=%d, elem1=%d, elem2=%d, elem3=%d", out0_int, out1_int, out2_int, out3_int);
    end
endmodule
