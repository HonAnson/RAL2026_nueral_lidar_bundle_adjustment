#!/usr/bin/env bash
#
# Like bundle.sh, but shrinks the images so the .zip fits submission limits.
#
#   ./commands/bundle_compressed.sh              # root.tex  -> root_compressed.zip
#   ./commands/bundle_compressed.sh mydoc.tex    # mydoc.tex -> mydoc_compressed.zip
#
# Same file selection as bundle.sh (main .tex, sections/*.tex, .bib/.cls/.sty/.bst,
# .bbl, and the images read during the last build per the .fls). Then, in a
# temporary staging copy (your repo is never modified):
#   - opaque PNGs (no alpha channel) are converted to JPEG, and every
#     reference to them in the staged .tex files is rewritten .png -> .jpg.
#     A conversion is kept only if the JPEG is actually smaller.
#   - before conversion, those opaque images are downscaled so their longest
#     side <= MAX_PX (never enlarged). In this paper they are the rendered /
#     raw / overview maps and thumbnails, printed <= ~1.5in wide, so 600px
#     is still >= 400 dpi in print.
#   - PNGs with transparency (plots, diagrams, colour bar) are left untouched:
#     JPEG would lose the alpha, and they hold text that should stay sharp.
#
# Tunables (environment variables):
#   JPEG_QUALITY=85   JPEG quality 1-100 (lower = smaller, more artefacts)
#   MAX_PX=600        max longest side for opaque images; 0 disables resizing
#   ALL_IMAGES=1      include the whole images/ folder instead of using the .fls
#   VERIFY=1          compile the staged bundle with latexmk to check it still builds
#
# Image tool: uses `sips` (built into macOS); falls back to ImageMagick
# (`magick` or `convert`) elsewhere.

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

TEXFILE="${1:-root.tex}"
TEXFILE="${TEXFILE%.tex}.tex"
BASE="${TEXFILE%.tex}"
OUT="${BASE}_compressed.zip"
JPEG_QUALITY="${JPEG_QUALITY:-85}"
MAX_PX="${MAX_PX:-600}"

if ! command -v zip >/dev/null 2>&1; then
    echo "error: zip not found in PATH." >&2
    exit 1
fi
if [[ ! -f "$TEXFILE" ]]; then
    echo "error: '$TEXFILE' not found in $ROOT_DIR" >&2
    exit 1
fi

# ---- pick an image backend ---------------------------------------------------
if command -v sips >/dev/null 2>&1; then
    IMG_TOOL=sips
elif command -v magick >/dev/null 2>&1; then
    IMG_TOOL=magick
elif command -v convert >/dev/null 2>&1; then
    IMG_TOOL=convert
else
    echo "error: need 'sips' (macOS) or ImageMagick ('magick'/'convert') to compress images." >&2
    exit 1
fi

has_alpha() {   # $1 = png ; exit 0 if it has an alpha channel
    case "$IMG_TOOL" in
        sips) sips -g hasAlpha "$1" 2>/dev/null | grep -q 'hasAlpha: yes' ;;
        *)    [[ "$("$IMG_TOOL" identify -format '%A' "$1" 2>/dev/null || identify -format '%A' "$1")" =~ ^([Tt]rue|[Bb]lend) ]] ;;
    esac
}

downscale() {   # $1 = image (in place); only shrinks, never enlarges
    [[ "$MAX_PX" -gt 0 ]] || return 0
    case "$IMG_TOOL" in
        sips)
            local w h
            w=$(sips -g pixelWidth  "$1" | awk '/pixelWidth/  {print $2}')
            h=$(sips -g pixelHeight "$1" | awk '/pixelHeight/ {print $2}')
            (( w > MAX_PX || h > MAX_PX )) || return 0   # sips -Z would upscale
            sips -Z "$MAX_PX" "$1" >/dev/null 2>&1 ;;
        *)  "$IMG_TOOL" "$1" -resize "${MAX_PX}x${MAX_PX}>" "$1" ;;
    esac
}

to_jpeg() {     # $1 = src png, $2 = dst jpg
    case "$IMG_TOOL" in
        sips) sips -s format jpeg -s formatOptions "$JPEG_QUALITY" "$1" --out "$2" >/dev/null 2>&1 ;;
        *)    "$IMG_TOOL" "$1" -quality "$JPEG_QUALITY" "$2" ;;
    esac
}

fsize() { wc -c < "$1" | tr -d ' '; }

# ---- collect files (same rules as bundle.sh) ---------------------------------
FILES=("$TEXFILE")
while IFS= read -r f; do FILES+=("$f"); done < <(find sections -type f -name '*.tex' 2>/dev/null | sort)
while IFS= read -r f; do FILES+=("$f"); done < <(find . -maxdepth 1 -type f \( -name '*.bib' -o -name '*.cls' -o -name '*.sty' -o -name '*.bst' \) | sed 's#^\./##' | sort)
[[ -f "${BASE}.bbl" ]] && FILES+=("${BASE}.bbl")

FLS="${BASE}.fls"
if [[ "${ALL_IMAGES:-0}" == "1" || ! -f "$FLS" ]]; then
    [[ -f "$FLS" ]] || echo "==> no $FLS found (run ./commands/compile.sh first to prune unused images); including all of images/"
    while IFS= read -r f; do FILES+=("$f"); done < <(find images -type f 2>/dev/null | sort)
else
    echo "==> selecting images from $FLS"
    while IFS= read -r f; do FILES+=("$f"); done < <(
        grep '^INPUT ' "$FLS" | sed -e 's/^INPUT //' -e 's#^\./##' | grep '^images/' | sort -u
    )
fi

MISSING=0
for f in "${FILES[@]}"; do
    if [[ ! -f "$f" ]]; then
        echo "error: '$f' listed for bundling but does not exist" >&2
        MISSING=1
    fi
done
[[ "$MISSING" == "0" ]] || exit 1

# ---- stage a copy ------------------------------------------------------------
STAGE="$(mktemp -d "${TMPDIR:-/tmp}/bundle_compressed.XXXXXX")"
trap 'rm -rf -- "$STAGE"' EXIT

for f in "${FILES[@]}"; do
    mkdir -p "$STAGE/$(dirname -- "$f")"
    cp -p -- "$f" "$STAGE/$f"
done

# ---- compress images in the stage --------------------------------------------
echo "==> compressing images with $IMG_TOOL (JPEG_QUALITY=$JPEG_QUALITY, MAX_PX=$MAX_PX)"
BEFORE=0; AFTER=0; CONVERTED=()
for f in "${FILES[@]}"; do
    [[ "$f" == images/* ]] || continue
    s="$STAGE/$f"
    BEFORE=$(( BEFORE + $(fsize "$s") ))
    if [[ "$f" == *.png || "$f" == *.PNG ]] && ! has_alpha "$s"; then
        downscale "$s"
        jpg="${s%.*}.jpg"
        if [[ -e "$jpg" ]]; then
            echo "   skip $f (a .jpg with the same name already exists)"
        elif to_jpeg "$s" "$jpg" && [[ -s "$jpg" ]] && (( $(fsize "$jpg") < $(fsize "$s") )); then
            rm -f -- "$s"
            CONVERTED+=("$f")
            s="$jpg"
        else
            rm -f -- "$jpg"
        fi
    fi
    AFTER=$(( AFTER + $(fsize "$s") ))
done

# Rewrite references images/foo.png -> images/foo.jpg in the staged .tex files.
# (References written without an extension resolve to the .jpg automatically.)
if (( ${#CONVERTED[@]} > 0 )); then
    TEXS=()
    while IFS= read -r t; do TEXS+=("$t"); done < <(find "$STAGE" -type f -name '*.tex')
    for f in "${CONVERTED[@]}"; do
        export OLD="$f" NEW="${f%.*}.jpg"
        perl -pi -e 's/\Q$ENV{OLD}\E/$ENV{NEW}/g' "${TEXS[@]}"
    done
fi

echo "==> images: $(( BEFORE / 1024 )) KB -> $(( AFTER / 1024 )) KB (${#CONVERTED[@]} PNG -> JPEG)"

# ---- optional build check ----------------------------------------------------
if [[ "${VERIFY:-0}" == "1" ]]; then
    if command -v latexmk >/dev/null 2>&1; then
        echo "==> VERIFY=1: compiling staged bundle"
        VDIR="$(mktemp -d "${TMPDIR:-/tmp}/bundle_verify.XXXXXX")"
        cp -R "$STAGE/." "$VDIR/"
        if (cd "$VDIR" && latexmk -pdf -interaction=nonstopmode -halt-on-error "$TEXFILE" >/dev/null 2>&1); then
            cp "$VDIR/${BASE}.pdf" "${BASE}_compressed_check.pdf"
            echo "    build OK -> ${BASE}_compressed_check.pdf (inspect the figures)"
            rm -rf -- "$VDIR"
        else
            echo "error: staged bundle failed to compile; log at $VDIR/${BASE}.log" >&2
            exit 1
        fi
    else
        echo "warning: VERIFY=1 but latexmk not found; skipping build check" >&2
    fi
fi

# ---- zip ---------------------------------------------------------------------
rm -f -- "$OUT"
(cd "$STAGE" && zip -q -X -9 -r "$ROOT_DIR/$OUT" .)
echo "==> $OUT  $(du -h "$OUT" | cut -f1)"
