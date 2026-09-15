# ---------------------------------------------------------------------------
# Cost-safety guardrail — created regardless of the harden flag. Emails you
# if your account's total spend crosses the threshold, so a forgotten
# resource (from this lab or anything else in your account) can't turn into
# a surprise bill.
# ---------------------------------------------------------------------------

resource "aws_budgets_budget" "guardrail" {
  name         = "${local.name_prefix}-budget-guardrail"
  budget_type  = "COST"
  limit_amount = tostring(var.budget_limit_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }
}
