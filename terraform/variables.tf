variable "aws_region" {
  description = "AWS region to deploy the lab into."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Short name used as a prefix for every resource, so everything this lab creates is easy to find and tear down."
  type        = string
  default     = "cloud-misconfig-lab"
}

variable "harden" {
  description = "false = vulnerable state (default, for the first scan). true = hardened state (re-apply this after your first scan, then re-scan)."
  type        = bool
  default     = false
}

variable "trusted_cidr" {
  description = "Your own IP in CIDR form (e.g. 203.0.113.4/32), used to scope SSH access ONLY when harden = true. Find yours with: curl -s ifconfig.me"
  type        = string
  default     = "203.0.113.0/32" # placeholder TEST-NET-3 address — overridden per your tfvars
}

variable "alert_email" {
  description = "Email address to receive the AWS Budget alert. Required — used only for the cost-safety guardrail."
  type        = string
}

variable "budget_limit_usd" {
  description = "Monthly spend threshold in USD that triggers the budget alert email."
  type        = number
  default     = 5
}
