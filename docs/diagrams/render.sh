#!/usr/bin/env bash
# Render every d2 diagram in the repo to an SVG sidecar with the First Motive
# font (Geist Mono). Diagram sources live next to the package they document
# (<package>/doc/diagrams/) plus the repo-level docs/diagrams/; the shared
# palette (styles.d2) and the font ship here, imported with a relative path.
# Self-contained: the font ships in fonts/, so anyone with the repo can
# re-render without installing fonts. Needs d2 on PATH (https://d2lang.com).
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"   # docs/diagrams
ROOT="$(cd "$HERE/../.." && pwd)"        # repo root
FONT="$HERE/fonts/GeistMono-VF.ttf"

if ! command -v d2 >/dev/null 2>&1; then
  echo "error: d2 not on PATH — install from https://d2lang.com" >&2
  exit 1
fi

# styles.d2 is an import-only palette, not a diagram.
find "$ROOT" -name '*.d2' ! -name 'styles.d2' -print0 | sort -z | while IFS= read -r -d '' f; do
  out="${f%.d2}.svg"
  d2 --layout elk \
    --font-regular "$FONT" --font-bold "$FONT" --font-italic "$FONT" \
    "$f" "$out"
  echo "rendered ${out#"$ROOT"/}"
done
