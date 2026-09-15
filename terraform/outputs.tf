output "bucket_name" {
  value       = aws_s3_bucket.vulnerable.bucket
  description = "The S3 bucket this lab created."
}

output "bucket_url" {
  value       = "https://${aws_s3_bucket.vulnerable.bucket}.s3.${var.aws_region}.amazonaws.com/${aws_s3_object.sample_sensitive_file.key}"
  description = "Direct URL to the sample file — works without any credentials when harden=false."
}

output "iam_role_arn" {
  value       = aws_iam_role.demo_role.arn
  description = "The IAM role carrying the (intentionally) overly-permissive policy when harden=false."
}

output "security_group_id" {
  value       = aws_security_group.open_ssh.id
  description = "The security group open to 0.0.0.0/0 on port 22 when harden=false."
}

output "ebs_snapshot_id" {
  value       = aws_ebs_snapshot.demo.id
  description = "The EBS snapshot made public when harden=false."
}

output "current_state" {
  value       = var.harden ? "HARDENED" : "VULNERABLE"
  description = "Which state this apply put the lab into."
}
