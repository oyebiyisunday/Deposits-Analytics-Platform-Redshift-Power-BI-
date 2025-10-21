#!/usr/bin/env bash
set -euo pipefail
OUT="${1:-dist/lineage.json}"
python3 scripts/lineage_capture.py --out "$OUT"
echo "Lineage written to $OUT"
