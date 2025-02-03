#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

mkdir -p bin

FILES=(
    src/main.asm
    src/defs.inc
    src/io.asm
)

TMP_ASM=$(mktemp /tmp/pbasic_XXXXXX.asm)
trap 'rm -f "$TMP_ASM"' EXIT

# Concatenate files that exist
for f in "${FILES[@]}"; do
    if [[ -f "$f" ]]; then
        cat "$f" >> "$TMP_ASM"
        echo "" >> "$TMP_ASM"
    fi
done

if command -v z80asm >/dev/null 2>&1; then
    z80asm -o bin/pbasic.bin "$TMP_ASM"
elif command -v sjasmplus >/dev/null 2>&1; then
    sjasmplus --raw=bin/pbasic.bin "$TMP_ASM"
else
    echo "Error: neither z80asm nor sjasmplus found" >&2
    exit 1
fi
