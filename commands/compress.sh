#!/usr/bin/env bash
#
# Shrink the compiled PDF with ghostscript, for submission size limits.
#
#   ./commands/compress.sh              # root.pdf   -> root_compressed.pdf
#   ./commands/compress.sh mydoc.pdf    # mydoc.pdf  -> mydoc_compressed.pdf
#
# Quality preset can be overridden, e.g.:
#   PDFSETTINGS=/ebook ./commands/compress.sh
# Presets, largest to smallest: /prepress /printer /ebook /screen

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BASE="${1:-root}"
BASE="${BASE%.pdf}"             # tolerate "root.pdf"
BASE="${BASE%.tex}"             # ... and "root.tex"
PDFFILE="${BASE}.pdf"
OUT="${BASE}_compressed.pdf"

PDFSETTINGS="${PDFSETTINGS:-/printer}"
COMPAT="${COMPAT:-1.5}"

if ! command -v gs >/dev/null 2>&1; then
    echo "error: ghostscript (gs) not found in PATH. Install it (e.g. 'sudo apt install ghostscript')." >&2
    exit 1
fi

if [[ ! -f "$PDFFILE" ]]; then
    echo "error: '$PDFFILE' not found in $ROOT_DIR -- run ./commands/compile.sh first." >&2
    exit 1
fi

echo "==> gs -dPDFSETTINGS=$PDFSETTINGS $PDFFILE -> $OUT"
gs -sDEVICE=pdfwrite \
   -dCompatibilityLevel="$COMPAT" \
   -dPDFSETTINGS="$PDFSETTINGS" \
   -dNOPAUSE -dBATCH -dQUIET \
   -sOutputFile="$OUT" \
   "$PDFFILE"

echo "==> $PDFFILE  $(du -h "$PDFFILE" | cut -f1)"
echo "==> $OUT  $(du -h "$OUT" | cut -f1)"
