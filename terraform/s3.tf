# ---------------------------------------------------------------------------
# Misconfiguration #1: public S3 bucket, no default encryption, no versioning
#
# AWS changed the default in 2023 so new buckets have ACLs disabled and
# public access blocked account-wide unless you explicitly opt out — which
# is itself the point: this file recreates the OLDER, less-safe default
# that caused so many public-bucket incidents, by explicitly re-enabling
# ACLs (ownership_controls) and turning off the public access block.
# ---------------------------------------------------------------------------

resource "aws_s3_bucket" "vulnerable" {
  bucket        = "${local.name_prefix}-data"
  force_destroy = true # allows `terraform destroy` to delete the bucket even though it holds an object

  tags = {
    Name = "${local.name_prefix}-data"
  }
}

resource "aws_s3_bucket_ownership_controls" "vulnerable" {
  bucket = aws_s3_bucket.vulnerable.id
  rule {
    object_ownership = "BucketOwnerPreferred" # required to allow ACLs at all on a modern bucket
  }
}

resource "aws_s3_bucket_public_access_block" "vulnerable" {
  bucket = aws_s3_bucket.vulnerable.id

  # When harden = false, every block is OFF (the vulnerable state).
  # When harden = true, every block is ON (the fix).
  block_public_acls       = var.harden
  block_public_policy     = var.harden
  ignore_public_acls      = var.harden
  restrict_public_buckets = var.harden
}

resource "aws_s3_bucket_acl" "vulnerable" {
  bucket = aws_s3_bucket.vulnerable.id
  acl    = var.harden ? "private" : "public-read"

  depends_on = [
    aws_s3_bucket_ownership_controls.vulnerable,
    aws_s3_bucket_public_access_block.vulnerable,
  ]
}

resource "aws_s3_bucket_versioning" "vulnerable" {
  bucket = aws_s3_bucket.vulnerable.id
  versioning_configuration {
    status = var.harden ? "Enabled" : "Suspended"
  }
}

# Default encryption only exists as a resource when hardened — the
# vulnerable state simply has none applied (Terraform's `count` toggle
# is how you conditionally omit a resource entirely).
resource "aws_s3_bucket_server_side_encryption_configuration" "vulnerable" {
  count  = var.harden ? 1 : 0
  bucket = aws_s3_bucket.vulnerable.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# A clearly-fake "sensitive" file so a scanner/screenshot has something
# concrete to point at. No real personal data — obviously fictional names.
resource "aws_s3_object" "sample_sensitive_file" {
  bucket       = aws_s3_bucket.vulnerable.id
  key          = "employee-records-DEMO.csv"
  content_type = "text/csv"
  content      = <<-EOT
    employee_id,full_name,department,note
    1001,Jane Doe,Engineering,FICTIONAL DEMO DATA - cloud-misconfig-lab
    1002,John Smith,Finance,FICTIONAL DEMO DATA - cloud-misconfig-lab
    1003,Alex Rivera,HR,FICTIONAL DEMO DATA - cloud-misconfig-lab
  EOT

  acl = var.harden ? "private" : "public-read"

  depends_on = [aws_s3_bucket_acl.vulnerable]
}
