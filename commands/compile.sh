#!/usr/bin/env bash
#
# Compile the response letter to PDF.
#
#   ./commands/compile.sh              # builds root.tex -> root.pdf
#   ./commands/compile.sh mydoc.tex    # builds a different document
#
# Runs from anywhere; always builds in the repository root.

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

TEXFILE="${1:-root.tex}"
TEXFILE="${TEXFILE%.tex}.tex"   # tolerate "root" as well as "root.tex"

if ! command -v latexmk >/dev/null 2>&1; then
    echo "error: latexmk not found in PATH. Install TeX Live (e.g. 'sudo apt install latexmk texlive-latex-extra')." >&2
    exit 1
fi

if [[ ! -f "$TEXFILE" ]]; then
    echo "error: '$TEXFILE' not found in $ROOT_DIR" >&2
    exit 1
fi

echo "==> latexmk -pdf $TEXFILE"
latexmk -pdf "$TEXFILE"

PDF="${TEXFILE%.tex}.pdf"
echo "==> built $PDF ($(du -h "$PDF" | cut -f1))"
