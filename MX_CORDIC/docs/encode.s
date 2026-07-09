# =====================================================================
# mx_encode.s -- RV32I (RISC-V 32-bit, so ISA base, sem Zbb/M)
#
# Traducao de: raw_u16_to_signed, encode_e5m2, mx_encode.
#
# NOTA IMPORTANTE: o Python usa int.bit_length(), que equivale a
# (32 - clz(x)) para x != 0. RV32I *puro* nao tem clz (isso e Zbb).
# Por isso adicionei uma funcao auxiliar msb_index(x) -- busca binaria
# classica que retorna o indice do bit mais significativo (0-indexado,
# equivalente a bit_length()-1 do Python). Se voce tiver Zbb disponivel
# no seu core, troque o corpo de msb_index por um simples:
#     clz  t0, a0
#     li   t1, 31
#     sub  a0, t1, t0
#     ret
# (3 instrucoes em vez de ~29). Deixei aqui a versao RV32I pura pois
# foi o que pediu para o modulo anterior.
#
# Assumo values[] como array de 4 int32 (ja sign-extended), no mesmo
# formato de bloco MX de 4 elementos do decoder anterior.
# =====================================================================

    .text
    .globl raw_u16_to_signed
    .globl msb_index
    .globl encode_e5m2
    .globl mx_encode

# ---------------------------------------------------------------------
# raw_u16_to_signed(value) -> int32
#   a0 (in)  = value (assume-se 0..0xFFFF, isto e, ja mascarado em 16b)
#   a0 (out) = valor sign-extended de 16 para 32 bits
# Isso e exatamente um sign-extend de 16 bits -- 2 instrucoes.
# ---------------------------------------------------------------------
raw_u16_to_signed:
    slli    a0, a0, 16
    srai    a0, a0, 16
    ret

# ---------------------------------------------------------------------
# msb_index(x) -> indice do bit mais significativo (0..31)
#   a0 (in)  = x (assume-se x != 0; comportamento indefinido se x==0,
#              igual ao bit_length()-1 do Python quando value==0 --
#              por isso os chamadores sempre testam ==0 antes)
#   a0 (out) = indice do MSB (equivalente a bit_length(x) - 1)
# Busca binaria classica (sem clz nativo). Funcao folha.
# ---------------------------------------------------------------------
msb_index:
    li      t0, 0                 # t0 = resultado acumulado

    li      t1, 0xFFFF0000
    and     t2, a0, t1
    beqz    t2, .L16
    srli    a0, a0, 16
    addi    t0, t0, 16
.L16:
    li      t1, 0xFF00
    and     t2, a0, t1
    beqz    t2, .L8
    srli    a0, a0, 8
    addi    t0, t0, 8
.L8:
    li      t1, 0xF0
    and     t2, a0, t1
    beqz    t2, .L4
    srli    a0, a0, 4
    addi    t0, t0, 4
.L4:
    li      t1, 0xC
    and     t2, a0, t1
    beqz    t2, .L2
    srli    a0, a0, 2
    addi    t0, t0, 2
.L2:
    li      t1, 0x2
    and     t2, a0, t1
    beqz    t2, .L1
    srli    a0, a0, 1
    addi    t0, t0, 1
.L1:
    add     a0, t0, a0            # soma o ultimo bit restante (0 ou 1)
    ret

# ---------------------------------------------------------------------
# encode_e5m2(value, scaled_magnitude) -> byte (em a0, bits 8..31 = 0)
#   a0 (in)  = value             (usado so para o sinal)
#   a1 (in)  = scaled_magnitude  (unsigned)
#   a0 (out) = byte E5M2 codificado
# ---------------------------------------------------------------------
encode_e5m2:
    addi    sp, sp, -16
    sw      ra, 12(sp)
    sw      s0,  8(sp)             # s0 = sign
    sw      s1,  4(sp)             # s1 = scaled_magnitude

    slti    s0, a0, 0              # s0 = (value < 0) ? 1 : 0
    beqz    a1, .Lzero_mag

    mv      s1, a1
    mv      a0, a1
    call    msb_index
    mv      t1, a0                 # t1 = msb

    addi    t2, t1, 15              # t2 = exp_value = msb + 15

    li      t3, 1
    blt     t2, t3, .Lexp_low       # exp_value < 1
    li      t3, 30
    ble     t2, t3, .Lexp_mid       # exp_value <= 30 -> caso "mid"

    # ---- exp_value > 30 ----
    li      t4, 30
    li      t5, 3
    j       .Lcombine

.Lexp_low:
    li      t4, 0
    li      t5, 0
    j       .Lcombine

.Lexp_mid:
    mv      t4, t2                  # exp = exp_value
    li      t6, 2
    blt     t1, t6, .Lmant_left     # msb < 2
    sub     t0, t1, t6              # t0 = msb - 2
    srl     t5, s1, t0
    andi    t5, t5, 0x3
    j       .Lcombine
.Lmant_left:
    li      t0, 2
    sub     t0, t0, t1              # t0 = 2 - msb
    sll     t5, s1, t0
    andi    t5, t5, 0x3
    j       .Lcombine

.Lcombine:
    slli    t6, s0, 7
    slli    t4, t4, 2
    or      t6, t6, t4
    or      a0, t6, t5
    j       .Lret

.Lzero_mag:
    slli    a0, s0, 7

.Lret:
    lw      ra, 12(sp)
    lw      s0,  8(sp)
    lw      s1,  4(sp)
    addi    sp, sp, 16
    ret

# ---------------------------------------------------------------------
# mx_encode(values_ptr, out_scale_ptr, out_overflow_ptr) -> elements
#   a0 (in)  = values_ptr        (int32 values[4])
#   a1 (in)  = out_scale_ptr     (uint8/int32 *)
#   a2 (in)  = out_overflow_ptr  (int32 * -- 0/1)
#   a0 (out) = elements (32 bits, 4 bytes E5M2 empacotados)
# ---------------------------------------------------------------------
mx_encode:
    addi    sp, sp, -64
    sw      ra,  60(sp)
    sw      s0,  56(sp)            # s0 = values_ptr
    sw      s1,  52(sp)            # s1 = out_scale_ptr
    sw      s2,  48(sp)            # s2 = out_overflow_ptr
    sw      s3,  44(sp)            # s3 = value0
    sw      s4,  40(sp)            # s4 = value1
    sw      s5,  36(sp)            # s5 = value2
    sw      s6,  32(sp)            # s6 = value3
    sw      s7,  28(sp)            # s7 = mag0 -> depois scaled0
    sw      s8,  24(sp)            # s8 = mag1 -> depois scaled1
    sw      s9,  20(sp)            # s9 = mag2 -> depois scaled2
    sw      s10, 16(sp)            # s10 = mag3 -> depois scaled3
    sw      s11, 12(sp)            # s11 = maximum / max_msb / elements

    mv      s0, a0
    mv      s1, a1
    mv      s2, a2

    lw      s3, 0(s0)
    lw      s4, 4(s0)
    lw      s5, 8(s0)
    lw      s6, 12(s0)

    # ---- magnitudes = abs(values) ----
    mv      t0, s3
    bgez    t0, .Lm0
    neg     t0, t0
.Lm0:
    mv      s7, t0

    mv      t0, s4
    bgez    t0, .Lm1
    neg     t0, t0
.Lm1:
    mv      s8, t0

    mv      t0, s5
    bgez    t0, .Lm2
    neg     t0, t0
.Lm2:
    mv      s9, t0

    mv      t0, s6
    bgez    t0, .Lm3
    neg     t0, t0
.Lm3:
    mv      s10, t0

    # ---- maximum = max(mag0..mag3) ----
    mv      s11, s7
    bge     s11, s8, .Lmx1
    mv      s11, s8
.Lmx1:
    bge     s11, s9, .Lmx2
    mv      s11, s9
.Lmx2:
    bge     s11, s10, .Lmx3
    mv      s11, s10
.Lmx3:

    bnez    s11, .Lnonzero_max

    # ---- maximum == 0 ----
    li      a0, 0
    li      t0, 0x7F
    sw      t0, 0(s1)
    li      t0, 0
    sw      t0, 0(s2)
    j       .Lmx_ret

.Lnonzero_max:
    mv      a0, s11
    call    msb_index
    mv      t1, a0                  # t1 = max_msb

    addi    t2, t1, -30             # t2 = scale_exp = max_msb - 30
    li      t3, 127
    li      t4, 0                   # t4 = overflow (bool)
    bgt     t2, t3, .Lset_ovf
    j       .Lclamp_lo
.Lset_ovf:
    li      t4, 1
.Lclamp_lo:
    li      t3, 127
    bgt     t2, t3, .Lclamp_hi2
    j       .Lclamp_lo2
.Lclamp_hi2:
    li      t2, 127
.Lclamp_lo2:
    li      t3, -127
    blt     t2, t3, .Lset_lo
    j       .Lscale_calc
.Lset_lo:
    li      t2, -127
.Lscale_calc:
    addi    t5, t2, 127             # t5 = scale
    li      t6, 0xFF
    bne     t5, t6, .Lscale_ok
    li      t5, 0xFE
    li      t4, 1                   # overflow = true
.Lscale_ok:
    sw      t5, 0(s1)               # *out_scale = scale
    sw      t4, 0(s2)               # *out_overflow = overflow

    # ---- shift_amount = 15 - max_msb ----
    li      t3, 15
    sub     t3, t3, t1

    # ---- scaled[i] = mag[i] << shift_amount ----
    sll     s7, s7, t3
    sll     s8, s8, t3
    sll     s9, s9, t3
    sll     s10, s10, t3

    # ---- elements = OR( encode_e5m2(value_i, scaled_i) << 8*i ) ----
    mv      a0, s3
    mv      a1, s7
    call    encode_e5m2
    mv      s11, a0                  # elements (byte 0, sem shift)

    mv      a0, s4
    mv      a1, s8
    call    encode_e5m2
    slli    t0, a0, 8
    or      s11, s11, t0

    mv      a0, s5
    mv      a1, s9
    call    encode_e5m2
    slli    t0, a0, 16
    or      s11, s11, t0

    mv      a0, s6
    mv      a1, s10
    call    encode_e5m2
    slli    t0, a0, 24
    or      s11, s11, t0

    mv      a0, s11

.Lmx_ret:
    lw      ra,  60(sp)
    lw      s0,  56(sp)
    lw      s1,  52(sp)
    lw      s2,  48(sp)
    lw      s3,  44(sp)
    lw      s4,  40(sp)
    lw      s5,  36(sp)
    lw      s6,  32(sp)
    lw      s7,  28(sp)
    lw      s8,  24(sp)
    lw      s9,  20(sp)
    lw      s10, 16(sp)
    lw      s11, 12(sp)
    addi    sp, sp, 64
    ret