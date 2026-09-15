#!/usr/bin/env bash
# Runs Prowler against your AWS account and saves the report under
# reports/prowler-<label>/. Run this twice: once as "before" (right after
# `terraform apply`, harden=false) and once as "after" (once you've
# re-applied with harden=true).
#
# Usage: ./run_prowler.sh before
#        ./run_prowler.sh after

set -euo pipefail

LABEL="${1:?Usage: $0 <label>, e.g. 'before' or 'after'}"
OUT_DIR="reports/prowler-${LABEL}"

if ! command -v prowler &>/dev/null; then
  echo "Prowler not found. Install it first: pip install prowler" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

echo "== Running Prowler (label: $LABEL) =="
echo "Output: $OUT_DIR"

# Flags verified against prowler/lib/cli/parser.py: -M/--output-modes takes
# csv, json, json-asff, html, json-ocsf. -o/--output-directory and
# -F/--output-filename set where/what it writes. These can still change
# across major Prowler releases — if this errors, run `prowler --help`.
prowler aws \
  --output-modes csv json-ocsf html \
  --output-directory "$OUT_DIR" \
  --output-filename "prowler-${LABEL}"

echo ""
echo "Done. JSON findings: $OUT_DIR/prowler-${LABEL}.ocsf.json"
echo "Open the HTML report in a browser for a readable summary/screenshot."
