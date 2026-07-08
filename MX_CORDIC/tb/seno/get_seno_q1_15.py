#!/usr/bin/env python3

import math
import sys


Q16_16_SCALE = 1 << 16
Q1_15_SCALE = 1 << 15
Q1_15_MIN = -(1 << 15)
Q1_15_MAX = (1 << 15) - 1


def raw_u32_to_signed(value):
    return value - (1 << 32) if value & 0x80000000 else value


def parse_input_line(line, line_number):
    fields = line.split()
    if not fields:
        return None
    if len(fields) != 1:
        raise ValueError(
            f"linha {line_number}: esperado um valor hexadecimal Q16.16"
        )

    try:
        raw_u32 = int(fields[0], 16)
    except ValueError as exc:
        raise ValueError(
            f"linha {line_number}: valor hexadecimal invalido"
        ) from exc

    if not 0 <= raw_u32 <= 0xFFFFFFFF:
        raise ValueError(f"linha {line_number}: valor excede 32 bits")

    return raw_u32_to_signed(raw_u32)


def sine_q1_15(angle_raw):
    angle_radians = angle_raw / Q16_16_SCALE
    result = round(math.sin(angle_radians) * Q1_15_SCALE)
    return max(Q1_15_MIN, min(Q1_15_MAX, result))


def generate_output(input_file, output_file):
    with open(input_file, encoding="utf-8") as fin, open(
        output_file, "w", encoding="utf-8"
    ) as fout:
        for line_number, line in enumerate(fin, start=1):
            angle_raw = parse_input_line(line, line_number)
            if angle_raw is not None:
                fout.write(f"{sine_q1_15(angle_raw)}\n")


def main():
    if len(sys.argv) != 3:
        print(
            "Uso: get_seno_q1_15.py <entrada.txt> <saida.txt>",
            file=sys.stderr,
        )
        return 1

    try:
        generate_output(sys.argv[1], sys.argv[2])
    except (OSError, ValueError) as exc:
        print(f"Erro: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
