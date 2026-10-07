# Threat Mapping

Each misconfiguration in this lab corresponds to a real category checked by
production CSPM tools and referenced in standard security frameworks.

**Note on control IDs:** CIS AWS Foundations Benchmark control numbers
differ across benchmark versions (v1.2, v1.4, v3.0, etc.), and MITRE
ATT&CK's Cloud matrix is revised periodically. Rather than pin specific
control numbers that could go stale, this table gives the *category* each
misconfiguration falls under and the corresponding ATT&CK technique; the
authoritative control ID for a given run is the one Prowler prints next to
each finding. Technique IDs can be checked against
[attack.mitre.org](https://attack.mitre.org/matrices/enterprise/cloud/).

| Misconfiguration | CIS AWS Foundations Benchmark category | MITRE ATT&CK (Cloud) |
|---|---|---|
| Public S3 bucket, no encryption, no versioning | S3 bucket public access / encryption controls (Prowler groups these under its "s3" service checks) | [T1530](https://attack.mitre.org/techniques/T1530/) — Data from Cloud Storage |
| Wildcard IAM policy (`*`/`*`) | IAM policy least-privilege controls (Prowler's "iam" service checks) | [T1078.004](https://attack.mitre.org/techniques/T1078/004/) — Valid Accounts: Cloud Accounts (an overly broad policy is what makes a single compromised credential catastrophic) |
| Security group open to `0.0.0.0/0` on port 22 | Network ACL / security group ingress controls (Prowler's "ec2" service checks) | [T1133](https://attack.mitre.org/techniques/T1133/) — External Remote Services |
| Public EBS snapshot | Storage resource sharing/exposure controls (Prowler's "ec2" service checks, snapshot-specific) | [T1530](https://attack.mitre.org/techniques/T1530/) — Data from Cloud Storage (same technique, different storage type — the snapshot need only be restored into an attacker-controlled account to read its contents) |
