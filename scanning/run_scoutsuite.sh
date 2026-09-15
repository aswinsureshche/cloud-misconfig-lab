#!/usr/bin/env bash
# Runs ScoutSuite against your AWS account for the browsable HTML report —
# useful for screenshots in your writeup, complementary to Prowler's
# per-check JSON output.
#
# Usage: ./run_scoutsuite.sh before
#        ./run_scoutsuite.sh after

set -euo pipefail

LABEL="${1:?Usage: $0 <label>, e.g. 'before' or 'after'}"
OUT_DIR="reports/scoutsuite-${LABEL}"

if ! command -v scout &>/dev/null; then
  echo "ScoutSuite not found. Install it first: pip install scoutsuite" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

echo "== Running ScoutSuite (label: $LABEL) =="
echo "Output: $OUT_DIR"

# --no-browser: don't try to auto-open a GUI browser from a headless/SSH
# session. Open the generated index.html manually afterward.
# -f/--force: overwrite if you re-run the same label.
scout aws --report-dir "$OUT_DIR" --no-browser --force

echo ""
echo "Done. Open $OUT_DIR/*/index.html in a browser to view the report."
