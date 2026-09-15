#!/usr/bin/env bash
# Safety-gated `terraform destroy`. Requires typing the project name back
# to confirm, same pattern as the attack-sim scripts in the Home SOC Lab —
# cheap insurance against destroying the wrong thing by muscle memory.
#
# Usage: ./destroy.sh

set -euo pipefail

TERRAFORM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../terraform" && pwd)"
cd "$TERRAFORM_DIR"

if [ ! -f terraform.tfstate ] && [ ! -f .terraform/terraform.tfstate ]; then
  echo "No local state file found in $TERRAFORM_DIR — nothing to destroy (or state is remote)."
  exit 0
fi

echo "This will destroy every resource this lab created in your AWS account."
echo "Working directory: $TERRAFORM_DIR"
echo ""
terraform plan -destroy -compact-warnings || true
echo ""
read -rp "Type 'destroy cloud-misconfig-lab' to confirm: " confirmation

if [ "$confirmation" != "destroy cloud-misconfig-lab" ]; then
  echo "Confirmation did not match. Aborting — nothing was destroyed." >&2
  exit 1
fi

terraform destroy -auto-approve

echo ""
echo "Destroy complete. Run ./verify_teardown.sh to double-check nothing billable is left."
