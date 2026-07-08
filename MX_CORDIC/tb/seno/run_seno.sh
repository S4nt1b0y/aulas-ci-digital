#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
INPUT_FILE="${1:-$SCRIPT_DIR/input.txt}"
PYTHON_OUTPUT="$SCRIPT_DIR/python_output.txt"
VERILOG_OUTPUT="$SCRIPT_DIR/verilog_output.txt"
SIMULATION_FILE="$(mktemp "${TMPDIR:-/tmp}/seno_tb.XXXXXX.vvp")"
TOLERANCE=409

cleanup() {
    rm -f -- "$SIMULATION_FILE"
}
trap cleanup EXIT

for command in python3 iverilog vvp awk; do
    if ! command -v "$command" >/dev/null 2>&1; then
        echo "Erro: comando '$command' nao encontrado." >&2
        exit 1
    fi
done

if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Erro: arquivo de entrada nao encontrado: $INPUT_FILE" >&2
    exit 1
fi

python3 "$SCRIPT_DIR/get_seno_q1_15.py" "$INPUT_FILE" "$PYTHON_OUTPUT"

iverilog -g2012 -Wall \
    -s seno_tb \
    -o "$SIMULATION_FILE" \
    "$PROJECT_DIR/src/phase_preprocess.v" \
    "$PROJECT_DIR/src/LUT_Seno.v" \
    "$PROJECT_DIR/src/phase_postprocess.v" \
    "$SCRIPT_DIR/seno_tb.v"

vvp "$SIMULATION_FILE" \
    "+INPUT=$INPUT_FILE" \
    "+OUTPUT=$VERILOG_OUTPUT"

awk -v tolerance="$TOLERANCE" '
    NR == FNR {
        expected[NR] = $1
        expected_count = NR
        next
    }
    {
        actual_count = FNR
        difference = expected[FNR] - $1
        if (difference < 0)
            difference = -difference
        if (difference > maximum)
            maximum = difference
        if (difference > tolerance) {
            printf "FAIL linha %d: Python=%d Verilog=%d erro=%d (limite=%d)\n", \
                   FNR, expected[FNR], $1, difference, tolerance > "/dev/stderr"
            failures++
        }
    }
    END {
        if (expected_count != actual_count) {
            printf "FAIL: quantidades diferentes: Python=%d Verilog=%d\n", \
                   expected_count, actual_count > "/dev/stderr"
            failures++
        }
        if (failures)
            exit 1
        printf "PASS: %d casos dentro da tolerancia Q1.15 de %d; erro maximo=%d.\n", \
               expected_count, tolerance, maximum
    }
' "$PYTHON_OUTPUT" "$VERILOG_OUTPUT"

echo "Python:  $PYTHON_OUTPUT"
echo "Verilog: $VERILOG_OUTPUT"
