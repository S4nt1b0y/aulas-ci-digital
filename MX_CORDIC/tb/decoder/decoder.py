import sys


INT32_MAX = 0x7FFFFFFF
INT32_MIN = -0x80000000


def decode_e5m2_base(fp):
    sign = (fp >> 7) & 0x1
    exp  = (fp >> 2) & 0x1F
    mant = fp & 0x03

    if exp == 0x1F:
        return None, 999

    elif exp == 0:
        if mant == 0:
            return 0, 0
        else:
            real_exp = -14 - 2
            value = mant
            if sign:
                value = -value
            return value, real_exp

    else:
        real_exp = exp - 15 - 2

        value = (1 << 2) | mant  # 1.M -> inteiro 1xx

        if sign:
            value = -value

        return value, real_exp

def apply_scale_to_int(base_val, total_exp):
    if base_val == 0:
        return 0

    if total_exp > 30:
        return INT32_MIN if base_val < 0 else INT32_MAX

    if total_exp < -32:
        return 0

    if total_exp >= 0:
        shifted = base_val << total_exp

        if shifted > INT32_MAX:
            return INT32_MAX

        if shifted < INT32_MIN:
            return INT32_MIN

        return shifted

    # Deslocar diretamente um valor negativo arredonda em direcao a -infinito.
    # A conversao para int32 definida para este decoder trunca em direcao a zero.
    magnitude = abs(base_val) >> (-total_exp)
    return -magnitude if base_val < 0 else magnitude

def mx_decode(elems_in, scale_in):

    fp0 = (elems_in >> 0)  & 0xFF
    fp1 = (elems_in >> 8)  & 0xFF
    fp2 = (elems_in >> 16) & 0xFF
    fp3 = (elems_in >> 24) & 0xFF

    b0, exp0 = decode_e5m2_base(fp0)
    b1, exp1 = decode_e5m2_base(fp1)
    b2, exp2 = decode_e5m2_base(fp2)
    b3, exp3 = decode_e5m2_base(fp3)

    if (
        scale_in == 0xFF
        or exp0 == 999
        or exp1 == 999
        or exp2 == 999
        or exp3 == 999
    ):
        return [0, 0, 0, 0], True

    scale_unbias = scale_in - 127

    out0 = apply_scale_to_int(b0, exp0 + scale_unbias)
    out1 = apply_scale_to_int(b1, exp1 + scale_unbias)
    out2 = apply_scale_to_int(b2, exp2 + scale_unbias)
    out3 = apply_scale_to_int(b3, exp3 + scale_unbias)

    return [out0, out1, out2, out3], False

def parse_input_line(line, line_number):
    fields = line.split()
    if not fields:
        return None
    if len(fields) != 2:
        raise ValueError(
            f"linha {line_number}: esperado '<elems_hex> <scale_hex>'"
        )

    try:
        elems_in = int(fields[0], 16)
        scale_in = int(fields[1], 16)
    except ValueError as exc:
        raise ValueError(f"linha {line_number}: valor hexadecimal invalido") from exc

    if not 0 <= elems_in <= 0xFFFFFFFF:
        raise ValueError(f"linha {line_number}: elems_in excede 32 bits")
    if not 0 <= scale_in <= 0xFF:
        raise ValueError(f"linha {line_number}: scale_in excede 8 bits")

    return elems_in, scale_in


def generate_output(input_file, output_file):
    with open(input_file, encoding="utf-8") as fin, open(
        output_file, "w", encoding="utf-8"
    ) as fout:
        for line_number, line in enumerate(fin, start=1):
            parsed = parse_input_line(line, line_number)
            if parsed is None:
                continue

            result, any_nan = mx_decode(*parsed)
            fout.write(
                f"{result[0]} {result[1]} {result[2]} {result[3]} "
                f"{int(any_nan)}\n"
            )

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Uso: decoder.py <entrada.txt> <saida.txt>")
        sys.exit(1)

    try:
        generate_output(sys.argv[1], sys.argv[2])
    except (OSError, ValueError) as exc:
        print(f"Erro: {exc}", file=sys.stderr)
        sys.exit(1)
