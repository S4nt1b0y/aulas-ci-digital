// Módulo Multiplicador CSA 4x4 com Registros
module multiplier_csa (
    input clk,
    input reset,
    input [3:0] multiplicand_in, 
    input [3:0] multiplier_in,   
    output [7:0] product_out     
);
    
    // --- 1. Registros de Entrada ---
    reg [3:0] r_multiplicand;
    reg [3:0] r_multiplier;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_multiplicand <= 4'h0;
            r_multiplier <= 4'h0;
        end else begin
            r_multiplicand <= multiplicand_in;
            r_multiplier <= multiplier_in;
        end
    end
    
    // --- 2. Lógica Combinacional (Core do Multiplicador 4x4) ---
    // Produtos Parciais (PP) - 4 produtos, 8 bits cada.
    wire [7:0] partial_products [3:0]; 
    
    // Geração dos 4 Produtos Parciais (PP0 a PP3)
    assign partial_products[0] = r_multiplier[0] ? (r_multiplicand << 0) : 8'h0; // PP0
    assign partial_products[1] = r_multiplier[1] ? (r_multiplicand << 1) : 8'h0; // PP1
    assign partial_products[2] = r_multiplier[2] ? (r_multiplicand << 2) : 8'h0; // PP2
    assign partial_products[3] = r_multiplier[3] ? (r_multiplicand << 3) : 8'h0; // PP3

    // Sinais Intermediários de Somas (Sum) e Carrys (Carry)
    wire [7:0] sum_stage1, sum_stage2;      
    wire [7:0] carry_stage1, carry_stage2;  
    wire [7:0] combinational_product;      

    // CSA 1: Reduz 3 PPs (PP0, PP1, PP2) em 2 vetores (Sum1, Carry1)
    // Usamos PP2 como A, PP0 como B e PP1 como Cin
    parameterized_csa #(8) csa_stage1 (
        .A(partial_products[2]),
        .B(partial_products[0]),
        .Cin(partial_products[1]),
        .Sum(sum_stage1),
        .Cout(carry_stage1)
    );

    // CSA 2: Reduz o último PP (PP3) e os vetores intermediários (Sum1, Carry1)
    // PP3 é o último produto parcial a ser somado
    parameterized_csa #(8) csa_stage2 (
        .A(partial_products[3]),
        .B(sum_stage1),
        .Cin(carry_stage1 << 1), // O vetor Carry deve ser deslocado em 1 bit
        .Sum(sum_stage2),
        .Cout(carry_stage2)
    );

    // Soma Final (RCA): Reduz os 2 vetores finais (Sum2, Carry2) no produto de 8 bits
    assign combinational_product = sum_stage2 + (carry_stage2 << 1); 

    
    // --- 3. Registro de Saída ---
    reg [7:0] r_product;
    
    always @(posedge clk or posedge reset) begin
        if (reset)
            r_product <= 8'h0;
        else
            r_product <= combinational_product; 
    end
    
    assign product_out = r_product;
endmodule