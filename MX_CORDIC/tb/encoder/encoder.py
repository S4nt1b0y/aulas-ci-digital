#!/usr/bin/env python3

import sys


def raw_u16_to_signed(value):
    return value - (1 << 16) if value & 0x8000 else value


def encode_e5m2(value, scaled_magnitude):
    sign = 1 if value < 0 else 0
    if scaled_magnitude == 0:
        return sign << 7

    msb = scaled_magnitude.bit_length() - 1
    exp_value = msb + 15
    if exp_value < 1:
        exp = 0
        mant = 0
    elif exp_value > 30:
        exp = 30
        mant = 3
    else:
        exp = exp_value
        if msb >= 2:
            mant = (scaled_magnitude >> (msb - 2)) & 0x3
        else:
            mant = (scaled_magnitude << (2 - msb)) & 0x3

    return (sign << 7) | (exp << 2) | mant


def mx_encode(values):
    magnitudes = [abs(value) for value in values]
    maximum = max(magnitudes)
    if maximum == 0:
        return 0, 0x7F, False

    max_msb = maximum.bit_length() - 1
    scale_exp = max_msb - 30
    overflow = scale_exp > 127
    scale_exp = max(-127, min(127, scale_exp))
    scale = scale_exp + 127
    if scale == 0xFF:
        scale = 0xFE
        overflow = True

    shift_amount = 15 - max_msb
    scaled = [magnitude << shift_amount for magnitude in magnitudes]
    elements = 0
    for index, (value, magnitude) in enumerate(zip(values, scaled)):
        elements |= encode_e5m2(value, magnitude) << (8 * index)

    return elements, scale, overflow


def parse_input_line(line, line_number):
    fields = line.split()
    if not fields:
        return None
    if len(fields) != 4:
        raise ValueError(
            f"linha {line_number}: esperados quatro valores hexadecimais Q1.15"
        )

    values = []
    for field in fields:
        try:
            raw_value = int(field, 16)
        except ValueError as exc:
            raise ValueError(
                f"linha {line_number}: valor hexadecimal invalido"
            ) from exc
        if not 0 <= raw_value <= 0xFFFF:
            raise ValueError(f"linha {line_number}: valor excede 16 bits")
        values.append(raw_u16_to_signed(raw_value))
    return values


def generate_output(input_file, output_file):
    with open(input_file, encoding="utf-8") as fin, open(
        output_file, "w", encoding="utf-8"
    ) as fout:
        for line_number, line in enumerate(fin, start=1):
            values = parse_input_line(line, line_number)
            if values is None:
                continue
            elements, scale, overflow = mx_encode(values)
            fout.write(f"{elements:08x} {scale:02x} {int(overflow)}\n")


def main():
    if len(sys.argv) != 3:
        print("Uso: encoder.py <entrada.txt> <saida.txt>", file=sys.stderr)
        return 1
    try:
        generate_output(sys.argv[1], sys.argv[2])
    except (OSError, ValueError) as exc:
        print(f"Erro: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
