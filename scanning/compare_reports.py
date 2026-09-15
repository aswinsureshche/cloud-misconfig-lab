#!/usr/bin/env python3
"""
Diffs two Prowler JSON-OCSF reports (before hardening vs. after) and prints
which findings were resolved, which are still failing, and whether anything
new showed up.

Field names below are verified against Prowler's own OCSF output model
(prowler/lib/outputs/models.py, class Check_Output_JSON_OCSF) rather than
guessed — each finding record looks like:

{
  "status": "Failure" | "Success" | "Other" | "Unknown",
  "severity": "Informational" | "Low" | "Medium" | "High" | "Critical" | "Fatal" | "Other",
  "status_detail": "...",
  "finding": {"uid": "...", "title": "...", "desc": "..."},
  "resources": [{"uid": "...", "name": "...", "region": "...", "type": "..."}],
  "compliance": {"status": "...", "requirements": [...]}
}

`finding.uid` is built as prowler-<provider>-<check_id>-<account>-<region>-
<resource_id>, which is stable across scans of the same account/resource —
that's what makes a before/after diff meaningful.

Usage:
    python3 compare_reports.py --before reports/prowler-before --after reports/prowler-after
"""
import argparse
import glob
import json
import sys
from pathlib import Path


def load_findings(report_dir: str) -> dict[str, dict]:
    """Load the *.ocsf.json file in a Prowler output directory and return
    {finding_uid: record} for every FAILING finding."""
    matches = glob.glob(str(Path(report_dir) / "*.ocsf.json"))
    if not matches:
        print(f"No *.ocsf.json file found in {report_dir}", file=sys.stderr)
        sys.exit(1)

    with open(matches[0]) as f:
        records = json.load(f)

    return {
        r["finding"]["uid"]: r
        for r in records
        if r.get("status") == "Failure"
    }


def describe(record: dict) -> str:
    title = record["finding"]["title"]
    severity = record.get("severity", "Unknown")
    resource = record["resources"][0] if record.get("resources") else {}
    resource_name = resource.get("name") or resource.get("uid", "unknown-resource")
    return f"[{severity}] {title} ({resource_name})"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--before", required=True, help="Directory from run_prowler.sh before")
    parser.add_argument("--after", required=True, help="Directory from run_prowler.sh after")
    args = parser.parse_args()

    before = load_findings(args.before)
    after = load_findings(args.after)

    resolved = set(before) - set(after)
    still_failing = set(before) & set(after)
    new_findings = set(after) - set(before)

    print(f"Findings before hardening: {len(before)} failing")
    print(f"Findings after hardening:  {len(after)} failing")
    print()

    print(f"=== RESOLVED ({len(resolved)}) ===")
    for uid in sorted(resolved):
        print(f"  ✓ {describe(before[uid])}")

    print()
    print(f"=== STILL FAILING ({len(still_failing)}) ===")
    for uid in sorted(still_failing):
        print(f"  ✗ {describe(after[uid])}")

    if new_findings:
        print()
        print(f"=== NEW FINDINGS ({len(new_findings)}) — investigate these ===")
        for uid in sorted(new_findings):
            print(f"  ! {describe(after[uid])}")

    print()
    if still_failing or new_findings:
        print("Hardening is incomplete — see above.")
        sys.exit(1)
    else:
        print("All findings from the vulnerable state were resolved.")


if __name__ == "__main__":
    main()
