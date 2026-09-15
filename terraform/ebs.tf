# ---------------------------------------------------------------------------
# Misconfiguration #4: a public EBS snapshot.
#
# Less well-known than public S3 buckets, but just as real: anyone in the
# world can search public snapshots and restore one into their own account
# to read its contents. Every CSPM tool checks for this specifically.
#
# This is a single 1 GiB unattached volume — nothing is running, nothing is
# attached to an instance, so cost is a fraction of a cent for the lab's
# lifetime.
#
# NOTE ON IMPLEMENTATION: making a snapshot public means granting the
# special "all" group createVolumePermission — Terraform's
# aws_snapshot_create_volume_permission resource only documents granting
# permission to a SPECIFIC account ID, not the "all" group, so this uses
# the AWS CLI directly (`modify-snapshot-attribute --group-names all`),
# which is the standard, documented way to do this. Requires the AWS CLI
# to be installed and already configured — the same credentials you used
# for `terraform init/apply`.
# ---------------------------------------------------------------------------

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_ebs_volume" "demo" {
  availability_zone = data.aws_availability_zones.available.names[0]
  size              = 1
  encrypted         = var.harden ? true : false

  tags = {
    Name = "${local.name_prefix}-volume"
  }
}

resource "aws_ebs_snapshot" "demo" {
  volume_id = aws_ebs_volume.demo.id

  tags = {
    Name = "${local.name_prefix}-snapshot"
  }
}

locals {
  snapshot_operation = var.harden ? "remove" : "add"
}

resource "null_resource" "snapshot_visibility" {
  # Re-runs whenever harden flips, or whenever the snapshot itself changes.
  triggers = {
    harden      = var.harden
    snapshot_id = aws_ebs_snapshot.demo.id
  }

  provisioner "local-exec" {
    command = "aws ec2 modify-snapshot-attribute --region ${var.aws_region} --snapshot-id ${aws_ebs_snapshot.demo.id} --attribute createVolumePermission --operation-type ${local.snapshot_operation} --group-names all"
  }
}
