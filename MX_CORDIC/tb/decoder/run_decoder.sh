#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
DEFAULT_INPUT="$SCRIPT_DIR/input.txt"
EXPECTED_OUTPUT="$SCRIPT_DIR/expected_output.txt"
INPUT_FILE="${1:-$DEFAULT_INPUT}"
PYTHON_OUTPUT="$SCRIPT_DIR/python_output.txt"
VERILOG_OUTPUT="$SCRIPT_DIR/verilog_output.txt"
SIMULATION_FILE="$(mktemp "${TMPDIR:-/tmp}/mx_decoder.XXXXXX.vvp")"

cleanup() {
    rm -f -- "$SIMULATION_FILE"
}
trap cleanup EXIT

for command in python3 iverilog vvp diff; do
    if ! command -v "$command" >/dev/null 2>&1; then
        echo "Erro: comando '$command' nao encontrado." >&2
        exit 1
    fi
done

if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Erro: arquivo de entrada nao encontrado: $INPUT_FILE" >&2
    exit 1
fi

python3 "$SCRIPT_DIR/decoder.py" "$INPUT_FILE" "$PYTHON_OUTPUT"

iverilog -g2012 -Wall \
    -s mx_decoder_tb \
    -o "$SIMULATION_FILE" \
    "$PROJECT_DIR/src/mx_decoder.v" \
    "$SCRIPT_DIR/mx_decoder_tb.v"

vvp "$SIMULATION_FILE" \
    "+INPUT=$INPUT_FILE" \
    "+OUTPUT=$VERILOG_OUTPUT"

if ! diff -u "$PYTHON_OUTPUT" "$VERILOG_OUTPUT"; then
    echo "FAIL: as saidas Python e Verilog divergem." >&2
    echo "Python:  $PYTHON_OUTPUT" >&2
    echo "Verilog: $VERILOG_OUTPUT" >&2
    exit 1
fi

if [[ "$INPUT_FILE" -ef "$DEFAULT_INPUT" ]]; then
    if ! diff -u "$EXPECTED_OUTPUT" "$PYTHON_OUTPUT"; then
        echo "FAIL: a saida Python diverge do golden Q16.16." >&2
        exit 1
    fi
    if ! diff -u "$EXPECTED_OUTPUT" "$VERILOG_OUTPUT"; then
        echo "FAIL: a saida Verilog diverge do golden Q16.16." >&2
        exit 1
    fi
    echo "PASS: Python, Verilog e golden Q16.16 produziram resultados identicos."
else
    echo "PASS: Python e Verilog produziram resultados Q16.16 identicos."
fi

echo "Python:  $PYTHON_OUTPUT"
echo "Verilog: $VERILOG_OUTPUT"
