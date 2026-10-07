# Cloud Misconfiguration Lab (AWS)

A self-contained lab that deliberately misconfigures a handful of AWS
resources the way real environments accidentally do, scans them with
open-source cloud security posture tools, remediates each finding, and
proves the fix with a re-scan.

This is infrastructure-as-code, not a fixed environment — the same
Terraform config can be applied in a **vulnerable** state or a **hardened**
state by flipping one variable, so the before/after comparison is exact.

> **Status (October 2026):** Infrastructure and tooling are complete. The
> first full scan → harden → re-scan run is in progress; Prowler/ScoutSuite
> results, screenshots, and a findings report will be added under `docs/`
> once it's done.

## What gets misconfigured, and why these four

| Resource | Misconfiguration | Real-world category |
|---|---|---|
| S3 bucket | Public read access, no default encryption, no versioning | Object storage exposure — one of the most commonly reported cloud data-exposure patterns |
| IAM policy | Wildcard `Action: "*"`, `Resource: "*"` attached to a role | Excessive privilege / lack of least-privilege |
| Security group | Ingress on port 22 (SSH) open to `0.0.0.0/0` | Network exposure of a management port to the entire internet |
| EBS snapshot | Marked public (`createVolumePermission` = all) | Block-storage exposure — less well-known than S3 but scanned for by every CSPM tool because a public snapshot can be restored by anyone into their own account |

These four span the categories a cloud security posture management (CSPM)
tool actually checks: storage, identity, network, and compute-adjacent
storage. No EC2 instance or RDS database is created, so the lab's ongoing
cost is effectively **cents, not dollars** — see [Cost](#cost) below.

## Tooling

- **[Prowler](https://github.com/prowler-cloud/prowler)** — open-source CLI that checks an AWS account against CIS AWS Foundations Benchmark controls and similar frameworks, one finding per check.
- **[ScoutSuite](https://github.com/nccgroup/ScoutSuite)** — open-source multi-service auditing tool that produces a browsable HTML report, useful for the visual/screenshot side of a writeup.
- A Python script (`scanning/compare_reports.py`) that diffs a Prowler run from before hardening against one from after, and prints which findings were resolved — the same "raw tool output → readable summary" pattern as the correlation engine in the [Home SOC Lab](https://github.com/aswinsureshche/home-soc-siem-lab).

## Repo layout

```
cloud-misconfig-lab/
├── terraform/              # the vulnerable/hardened infrastructure, toggled by var.harden
│   ├── main.tf
│   ├── variables.tf
│   ├── s3.tf
│   ├── iam.tf
│   ├── network.tf
│   ├── ebs.tf
│   ├── budget.tf            # cost-safety guardrail, always created
│   ├── outputs.tf
│   └── terraform.tfvars.example
├── scanning/
│   ├── run_prowler.sh
│   ├── run_scoutsuite.sh
│   └── compare_reports.py
├── teardown/
│   ├── destroy.sh            # safety-gated terraform destroy
│   └── verify_teardown.sh    # confirms nothing was left running/billable
└── docs/
    ├── walkthrough.md        # step-by-step run order + a findings template for YOUR writeup
    └── threat-mapping.md     # each misconfig mapped to CIS + MITRE ATT&CK Cloud
```

## Prerequisites

- An AWS account (free tier is fine) with billing alerts already enabled at the account level, in addition to the budget this lab creates
- The AWS CLI installed and configured with credentials that have admin access **in a throwaway/lab account or a dedicated IAM user** — run `aws configure` yourself; never put access keys in any file in this repo
- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- Python 3.10+ for the scanning tools and comparison script

## Run order

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars   # fill in your own values
terraform init
terraform apply                                 # harden = false by default: this is the VULNERABLE state
```

```bash
cd ../scanning
pip install prowler scoutsuite
./run_prowler.sh before                         # writes reports/prowler-before/
./run_scoutsuite.sh before                       # optional, for the HTML report
```

```bash
cd ../terraform
terraform apply -var="harden=true"              # re-applies the SAME resources, now hardened
```

```bash
cd ../scanning
./run_prowler.sh after                          # writes reports/prowler-after/
python3 compare_reports.py --before reports/prowler-before --after reports/prowler-after
```

```bash
cd ../teardown
./destroy.sh                                    # tears everything down, with a typed confirmation
./verify_teardown.sh                            # double-checks nothing billable is still running
```

Full walkthrough with explanations at each step: [docs/walkthrough.md](docs/walkthrough.md).

## Cost

Nothing here runs a server. An S3 bucket holding one small file, an IAM
policy/role, a security group, and a 1 GB EBS volume/snapshot cost a few
cents at most for the hour or two you'll have this up, and the budget in
`terraform/budget.tf` emails you if spend crosses a threshold you set
(default $5). Run `teardown/verify_teardown.sh` when you're done so nothing
keeps accruing charges after you've written up your findings.

## Why this is real, not toy

Every finding here maps to an actual industry framework check — see
[docs/threat-mapping.md](docs/threat-mapping.md) for the CIS AWS Foundations
Benchmark control and MITRE ATT&CK Cloud technique behind each one. Prowler
and ScoutSuite are the same tools used in real cloud security assessments,
not lab-only substitutes — running them against your own deliberately
misconfigured account and then fixing what they find is functionally the
same exercise a junior cloud security engineer does in their first month on
the job.
