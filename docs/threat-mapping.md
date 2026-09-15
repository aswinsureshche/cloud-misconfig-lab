# Threat Mapping

Each misconfiguration in this lab corresponds to a real category checked by
production CSPM tools and referenced in standard security frameworks.

**A caveat worth stating in your own writeup**: CIS AWS Foundations
Benchmark control numbers differ across benchmark versions (v1.2, v1.4,
v3.0, etc.), and MITRE ATT&CK's Cloud matrix is revised periodically. Rather
than assert specific control numbers here that could be stale by the time
you run this, use the exact control ID Prowler prints next to each finding
in its own output — that's the authoritative, current mapping. The table
below gives you the *category* to look for and a defensible MITRE technique,
both worth double-checking against [attack.mitre.org](https://attack.mitre.org/matrices/enterprise/cloud/)
before you cite a specific ID in a resume/interview context.

| Misconfiguration | CIS AWS Foundations Benchmark category | MITRE ATT&CK (Cloud) |
|---|---|---|
| Public S3 bucket, no encryption, no versioning | S3 bucket public access / encryption controls (Prowler groups these under its "s3" service checks) | [T1530](https://attack.mitre.org/techniques/T1530/) — Data from Cloud Storage |
| Wildcard IAM policy (`*`/`*`) | IAM policy least-privilege controls (Prowler's "iam" service checks) | [T1078.004](https://attack.mitre.org/techniques/T1078/004/) — Valid Accounts: Cloud Accounts (an overly broad policy is what makes a single compromised credential catastrophic) |
| Security group open to `0.0.0.0/0` on port 22 | Network ACL / security group ingress controls (Prowler's "ec2" service checks) | [T1133](https://attack.mitre.org/techniques/T1133/) — External Remote Services |
| Public EBS snapshot | Storage resource sharing/exposure controls (Prowler's "ec2" service checks, snapshot-specific) | [T1530](https://attack.mitre.org/techniques/T1530/) — Data from Cloud Storage (same technique, different storage type — the snapshot need only be restored into an attacker-controlled account to read its contents) |

## Why this framing matters for a portfolio project

Anyone can misconfigure a cloud resource. What a scanner-plus-remediation
project like this one actually demonstrates is that you understand *why*
each finding matters — not just that a tool flagged it. When you talk about
this project, lead with the category (public storage exposure, excessive
privilege, network exposure) rather than the specific check ID, and be ready
to explain the actual attack path each one enables: what could someone
*do* with a public S3 bucket / an admin-privileged role / an open SSH port /
a public snapshot, concretely, in your own words.
