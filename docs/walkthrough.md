# Walkthrough

Step-by-step run order, with a findings template at the bottom for your own
writeup. The template is intentionally left blank — fill it in with your
own screenshots and output, not anything pasted from elsewhere, since this
is the part that's actually yours.

## 0. Prerequisites

```bash
aws configure    # your own credentials — never put these in any file in this repo
terraform -version   # >= 1.5
python3 --version    # >= 3.10
```

Enable account-level billing alerts too (Billing console → Billing
Preferences → Receive Billing Alerts), on top of the Terraform-managed
budget guardrail — belt and suspenders.

## 1. Stand up the vulnerable state

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars: set alert_email, and trusted_cidr (curl -s ifconfig.me)
terraform init
terraform apply
```

Review the plan output before typing `yes` — you should see it creating an
S3 bucket, IAM role/policy, VPC/subnet/security group, EBS volume/snapshot,
and a budget. Note the outputs (`bucket_name`, `security_group_id`, etc.) —
you'll want them in your writeup.

## 2. Scan the vulnerable state

```bash
cd ../scanning
pip install prowler scoutsuite
./run_prowler.sh before
./run_scoutsuite.sh before      # optional, for the HTML visual report
```

Open `reports/prowler-before/prowler-before.html` in a browser. **Screenshot
this** — it's your primary "before" evidence.

## 3. Harden it

```bash
cd ../terraform
terraform apply -var="harden=true"
```

Same resources, hardened configuration — review the plan diff, it should
show the public access block being enabled, the IAM policy narrowing, the
security group's CIDR narrowing to your IP, and the snapshot permission
being removed.

## 4. Scan the hardened state and compare

```bash
cd ../scanning
./run_prowler.sh after
python3 compare_reports.py --before reports/prowler-before --after reports/prowler-after
```

This prints exactly which findings were resolved. **This output is your
core evidence** — save it (`> comparison-output.txt`) for your writeup.

## 5. Tear down

```bash
cd ../teardown
./destroy.sh
./verify_teardown.sh
```

Confirm `verify_teardown.sh` reports clean before you walk away.

---

## Findings template — fill this in yourself

Copy this section into your own writeup (a new doc, a GitHub wiki page,
whatever you use) and replace every bracket with your actual results.

### Cloud Misconfiguration Lab — Findings Report

**Date:** [ ]
**AWS Account:** [last 4 digits only, never the full account ID]
**Tools used:** Terraform, Prowler [version], ScoutSuite [version]

#### Summary

[1-2 sentences: what you built, what you found, what you fixed]

#### Finding 1: Public S3 Bucket

- **Before:** [paste the relevant Prowler finding line / screenshot reference]
- **Attack scenario:** [in your own words — what could someone do with this?]
- **Fix applied:** [what the Terraform hardening actually changed]
- **After:** [confirm resolved, from compare_reports.py output]

#### Finding 2: Overly Permissive IAM Policy

- **Before:** [ ]
- **Attack scenario:** [ ]
- **Fix applied:** [ ]
- **After:** [ ]

#### Finding 3: Open Security Group (SSH)

- **Before:** [ ]
- **Attack scenario:** [ ]
- **Fix applied:** [ ]
- **After:** [ ]

#### Finding 4: Public EBS Snapshot

- **Before:** [ ]
- **Attack scenario:** [ ]
- **Fix applied:** [ ]
- **After:** [ ]

#### Lessons learned

[What surprised you? What would you check for first in a real environment
after doing this?]
