#!/usr/bin/env bash
#
# Remove all LaTeX build artefacts, including the generated PDF.
#
#   ./commands/clean.sh              # cleans after root.tex
#   ./commands/clean.sh mydoc.tex    # cleans after a different document
#
# Also removes the ghostscript-compressed PDF produced by compress.sh.

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

TEXFILE="${1:-root.tex}"
TEXFILE="${TEXFILE%.tex}.tex"
BASE="${TEXFILE%.tex}"

if ! command -v latexmk >/dev/null 2>&1; then
    echo "error: latexmk not found in PATH." >&2
    exit 1
fi

if [[ ! -f "$TEXFILE" ]]; then
    echo "error: '$TEXFILE' not found in $ROOT_DIR" >&2
    exit 1
fi

echo "==> latexmk -C $TEXFILE"
latexmk -C "$TEXFILE"

# latexmk -C does not know about the compressed copy; drop it too.
if [[ -f "${BASE}_compressed.pdf" ]]; then
    rm -f -- "${BASE}_compressed.pdf"
    echo "==> removed ${BASE}_compressed.pdf"
fi

echo "==> clean"
