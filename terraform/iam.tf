# ---------------------------------------------------------------------------
# Misconfiguration #2: an IAM policy that grants full admin access ("*"/"*")
# instead of being scoped to only what the role actually needs.
# ---------------------------------------------------------------------------

resource "aws_iam_role" "demo_role" {
  name = "${local.name_prefix}-demo-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "demo_policy" {
  name        = "${local.name_prefix}-policy"
  description = "Intentionally overly-permissive when harden=false; scoped down when harden=true."

  # Vulnerable: Action "*" on Resource "*" — full administrative access.
  # Hardened: read-only access, and only to this lab's own S3 bucket.
  policy = var.harden ? jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:ListBucket",
      ]
      Resource = [
        aws_s3_bucket.vulnerable.arn,
        "${aws_s3_bucket.vulnerable.arn}/*",
      ]
    }]
    }) : jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "*"
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "demo_attachment" {
  role       = aws_iam_role.demo_role.name
  policy_arn = aws_iam_policy.demo_policy.arn
}
