# =====================================================================
# mx_decode.s -- RV32I (RISC-V 32-bit, so ISA base, sem extensoes)
#
# Traducao do nucleo numerico do decoder MX FP8 E5M2 -> Q16.16.
# Nao inclui parse_input_line/generate_output (I/O de host, irrelevante
# para estimativa de instrucoes de hardware).
#
# Convencao de chamada: padrao RISC-V (a0-a7 args/retorno, ra=x1,
# sp=x2, s0-s11 salvos pela callee, t0-t6 temporarios).
# =====================================================================

    .text
    .globl decode_e5m2_base
    .globl apply_scale_to_q16_16
    .globl mx_decode

# ---------------------------------------------------------------------
# decode_e5m2_base(fp) -> (base_val, exp)
#   a0 (in)  = fp (byte, 0..255)
#   a0 (out) = base_val
#   a1 (out) = exp   (999 = sentinela de NaN/Inf, igual ao Python)
# Funcao folha, nao mexe na pilha.
# ---------------------------------------------------------------------
decode_e5m2_base:
    srli    t1, a0, 7
    andi    t1, t1, 1          # t1 = sign
    srli    t2, a0, 2
    andi    t2, t2, 0x1F       # t2 = exp
    andi    t3, a0, 0x3        # t3 = mant

    li      t4, 0x1F
    bne     t2, t4, .Lnot_nan
    li      a0, 0
    li      a1, 999
    ret

.Lnot_nan:
    bnez    t2, .Lnormal

    # exp == 0 (subnormal ou zero)
    bnez    t3, .Lsubnormal
    li      a0, 0
    li      a1, 0
    ret

.Lsubnormal:
    mv      a0, t3
    beqz    t1, .Lsub_pos
    neg     a0, a0
.Lsub_pos:
    li      a1, -16             # -14 - 2
    ret

.Lnormal:
    addi    a1, t2, -17         # exp - 15 - 2
    ori     a0, t3, 4           # (1<<2) | mant
    beqz    t1, .Lnorm_pos
    neg     a0, a0
.Lnorm_pos:
    ret

# ---------------------------------------------------------------------
# apply_scale_to_q16_16(base_val, total_exp) -> int32
#   a0 (in)  = base_val
#   a1 (in)  = total_exp
#   a0 (out) = resultado Q16.16 saturado em [INT32_MIN, INT32_MAX]
# Funcao folha.
# ---------------------------------------------------------------------
apply_scale_to_q16_16:
    beqz    a0, .Lret_zero

    li      t3, 30
    blt     t3, a1, .Lclamp_hi   # total_exp > 30
    li      t3, -32
    blt     a1, t3, .Lret_zero   # total_exp < -32

    bltz    a1, .Llt0
    # ---- total_exp >= 0 ----
    sll     t0, a0, a1           # shifted = base_val << total_exp
    sra     t1, t0, a1           # desfaz o shift p/ detectar overflow
    beq     t1, a0, .Lno_overflow
    bltz    a0, .Lret_min
    li      a0, 0x7FFFFFFF       # INT32_MAX
    ret
.Lno_overflow:
    mv      a0, t0
    ret

.Llt0:
    # magnitude = abs(base_val) >> (-total_exp)
    mv      t0, a0
    bgez    t0, .Labs_done
    neg     t0, t0
.Labs_done:
    neg     t2, a1               # t2 = -total_exp  (1..32)
    li      t5, 32
    beq     t2, t5, .Lshift32    # RV32 shift usa so os 5 bits baixos!
    srl     t0, t0, t2
    j       .Lapply_sign
.Lshift32:
    li      t0, 0
.Lapply_sign:
    bltz    a0, .Lneg_res
    mv      a0, t0
    ret
.Lneg_res:
    neg     a0, t0
    ret

.Lclamp_hi:
    bltz    a0, .Lret_min
    li      a0, 0x7FFFFFFF
    ret
.Lret_min:
    li      a0, 0x80000000
    ret
.Lret_zero:
    li      a0, 0
    ret

# ---------------------------------------------------------------------
# mx_decode(elems_in, scale_in, out_ptr) -> any_nan
#   a0 (in)  = elems_in  (32 bits, 4 bytes E5M2 empacotados)
#   a1 (in)  = scale_in  (8 bits)
#   a2 (in)  = out_ptr   (int32 out[4])
#   a0 (out) = any_nan (0 ou 1)
# ---------------------------------------------------------------------
mx_decode:
    addi    sp, sp, -48
    sw      ra,  44(sp)
    sw      s0,  40(sp)         # s0 = elems_in
    sw      s1,  36(sp)         # s1 = out_ptr
    sw      s2,  32(sp)         # s2 = scale_in / scale_unbias depois
    sw      s3,  28(sp)         # s3 = b0
    sw      s4,  24(sp)         # s4 = exp0
    sw      s5,  20(sp)         # s5 = b1
    sw      s6,  16(sp)         # s6 = exp1
    sw      s7,  12(sp)         # s7 = b2
    sw      s8,   8(sp)         # s8 = exp2
    sw      s9,   4(sp)         # s9 = b3
    sw      s10,  0(sp)         # s10 = exp3

    mv      s0, a0
    mv      s1, a2
    mv      s2, a1

    # ---- fp0 ----
    andi    a0, s0, 0xFF
    call    decode_e5m2_base
    mv      s3, a0
    mv      s4, a1

    # ---- fp1 ----
    srli    a0, s0, 8
    andi    a0, a0, 0xFF
    call    decode_e5m2_base
    mv      s5, a0
    mv      s6, a1

    # ---- fp2 ----
    srli    a0, s0, 16
    andi    a0, a0, 0xFF
    call    decode_e5m2_base
    mv      s7, a0
    mv      s8, a1

    # ---- fp3 ----
    srli    a0, s0, 24
    andi    a0, a0, 0xFF        # ja e so 8 bits, mas mantem simetria
    call    decode_e5m2_base
    mv      s9, a0
    mv      s10, a1

    # ---- checa NaN/Inf (scale==0xFF ou algum exp==999) ----
    li      t0, 0xFF
    beq     s2, t0, .Lnan_path
    li      t0, 999
    beq     s4,  t0, .Lnan_path
    beq     s6,  t0, .Lnan_path
    beq     s8,  t0, .Lnan_path
    beq     s10, t0, .Lnan_path

    # ---- caminho normal ----
    addi    s2, s2, -127        # s2 = scale_unbias

    add     a1, s4, s2
    addi    a1, a1, 16
    mv      a0, s3
    call    apply_scale_to_q16_16
    sw      a0, 0(s1)

    add     a1, s6, s2
    addi    a1, a1, 16
    mv      a0, s5
    call    apply_scale_to_q16_16
    sw      a0, 4(s1)

    add     a1, s8, s2
    addi    a1, a1, 16
    mv      a0, s7
    call    apply_scale_to_q16_16
    sw      a0, 8(s1)

    add     a1, s10, s2
    addi    a1, a1, 16
    mv      a0, s9
    call    apply_scale_to_q16_16
    sw      a0, 12(s1)

    li      a0, 0                # any_nan = false
    j       .Lmx_ret

.Lnan_path:
    sw      x0, 0(s1)
    sw      x0, 4(s1)
    sw      x0, 8(s1)
    sw      x0, 12(s1)
    li      a0, 1                # any_nan = true

.Lmx_ret:
    lw      ra,  44(sp)
    lw      s0,  40(sp)
    lw      s1,  36(sp)
    lw      s2,  32(sp)
    lw      s3,  28(sp)
    lw      s4,  24(sp)
    lw      s5,  20(sp)
    lw      s6,  16(sp)
    lw      s7,  12(sp)
    lw      s8,   8(sp)
    lw      s9,   4(sp)
    lw      s10,  0(sp)
    addi    sp, sp, 48
    ret