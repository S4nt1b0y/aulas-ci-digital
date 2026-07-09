#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
SIMULATION_FILE="$(mktemp "${TMPDIR:-/tmp}/mx_sin_apb4.XXXXXX.vvp")"

cleanup() {
    rm -f -- "$SIMULATION_FILE"
}
trap cleanup EXIT

for command in iverilog vvp; do
    if ! command -v "$command" >/dev/null 2>&1; then
        echo "Erro: comando '$command' nao encontrado." >&2
        exit 1
    fi
done

iverilog -g2012 -Wall \
    -s mx_sin_apb4_tb \
    -o "$SIMULATION_FILE" \
    "$PROJECT_DIR/src/apb4/apb4_slave.v" \
    "$PROJECT_DIR/src/mx_decoder.v" \
    "$PROJECT_DIR/src/phase_preprocess.v" \
    "$PROJECT_DIR/src/LUT_Seno.v" \
    "$PROJECT_DIR/src/phase_postprocess.v" \
    "$PROJECT_DIR/src/mx_encoder.v" \
    "$PROJECT_DIR/src/mx_sin.v" \
    "$PROJECT_DIR/src/mx_sin_apb4_top.v" \
    "$SCRIPT_DIR/mx_sin_apb4_tb.v"

vvp "$SIMULATION_FILE"
