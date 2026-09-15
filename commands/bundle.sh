#!/usr/bin/env bash
#
# Bundle the LaTeX sources into a .zip ready to upload to Overleaf.
#
#   ./commands/bundle.sh              # root.tex   -> root_overleaf.zip
#   ./commands/bundle.sh mydoc.tex    # mydoc.tex  -> mydoc_overleaf.zip
#
# What goes in:
#   - the main .tex, every \input/\include'd .tex, .bib and .cls/.sty files
#   - only the images actually read during the last build (from the .fls file
#     that latexmk writes); if no .fls exists the whole images/ folder is used
#   - the .bbl if present, so Overleaf can render before running BibTeX
#
# Set ALL_IMAGES=1 to force including the whole images/ folder regardless.
#
# Runs from anywhere; always bundles from the repository root.

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

TEXFILE="${1:-root.tex}"
TEXFILE="${TEXFILE%.tex}.tex"   # tolerate "root" as well as "root.tex"
BASE="${TEXFILE%.tex}"
OUT="${BASE}_overleaf.zip"

if ! command -v zip >/dev/null 2>&1; then
    echo "error: zip not found in PATH. Install it (e.g. 'sudo apt install zip')." >&2
    exit 1
fi

if [[ ! -f "$TEXFILE" ]]; then
    echo "error: '$TEXFILE' not found in $ROOT_DIR" >&2
    exit 1
fi

FILES=()

# Always-included sources: main tex, sections, bibliography, class/style files.
FILES+=("$TEXFILE")
while IFS= read -r f; do FILES+=("$f"); done < <(find sections -type f -name '*.tex' 2>/dev/null | sort)
while IFS= read -r f; do FILES+=("$f"); done < <(find . -maxdepth 1 -type f \( -name '*.bib' -o -name '*.cls' -o -name '*.sty' -o -name '*.bst' \) -printf '%P\n' | sort)
[[ -f "${BASE}.bbl" ]] && FILES+=("${BASE}.bbl")

# Images: prefer the exact set the last build read (recorded in the .fls).
FLS="${BASE}.fls"
if [[ "${ALL_IMAGES:-0}" == "1" || ! -f "$FLS" ]]; then
    [[ -f "$FLS" ]] || echo "==> no $FLS found (run ./commands/compile.sh first to prune unused images); including all of images/"
    while IFS= read -r f; do FILES+=("$f"); done < <(find images -type f 2>/dev/null | sort)
else
    echo "==> selecting images from $FLS"
    while IFS= read -r f; do FILES+=("$f"); done < <(
        grep '^INPUT ' "$FLS" | sed -e 's/^INPUT //' -e 's#^\./##' \
            | grep '^images/' | sort -u
    )
fi

# Sanity check: refuse to bundle if any referenced file is missing.
MISSING=0
for f in "${FILES[@]}"; do
    if [[ ! -f "$f" ]]; then
        echo "error: '$f' listed for bundling but does not exist" >&2
        MISSING=1
    fi
done
[[ "$MISSING" == "0" ]] || exit 1

rm -f -- "$OUT"
echo "==> zipping ${#FILES[@]} files -> $OUT"
zip -q -X "$OUT" "${FILES[@]}"

echo "==> $OUT  $(du -h "$OUT" | cut -f1)"
