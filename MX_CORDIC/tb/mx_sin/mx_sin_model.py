#!/usr/bin/env python3

import sys
from pathlib import Path


THIS_DIR = Path(__file__).resolve().parent
TB_DIR = THIS_DIR.parent
sys.path.insert(0, str(TB_DIR / "decoder"))
sys.path.insert(0, str(TB_DIR / "encoder"))
sys.path.insert(0, str(TB_DIR / "seno"))

from decoder import mx_decode, parse_input_line
from encoder import mx_encode
from get_seno_q1_15 import sine_q1_15


def mx_sin_model(elems_in, scale_in):
    phases, any_nan = mx_decode(elems_in, scale_in)
    sines = [sine_q1_15(phase) for phase in phases]
    elems_out, scale_out, overflow = mx_encode(sines)
    return elems_out, scale_out, any_nan, overflow


def generate_output(input_file, output_file):
    with open(input_file, encoding="utf-8") as fin, open(
        output_file, "w", encoding="utf-8"
    ) as fout:
        for line_number, line in enumerate(fin, start=1):
            parsed = parse_input_line(line, line_number)
            if parsed is None:
                continue

            elems_out, scale_out, any_nan, overflow = mx_sin_model(*parsed)
            fout.write(
                f"{elems_out:08x} {scale_out:02x} "
                f"{int(any_nan)} {int(overflow)}\n"
            )


def main():
    if len(sys.argv) != 3:
        print("Uso: mx_sin_model.py <entrada.txt> <saida.txt>", file=sys.stderr)
        return 1

    try:
        generate_output(sys.argv[1], sys.argv[2])
    except (OSError, ValueError) as exc:
        print(f"Erro: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
