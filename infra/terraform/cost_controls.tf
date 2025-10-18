resource "aws_budgets_budget" "monthly" {
  count        = var.enable_budgets ? 1 : 0
  name         = "${var.project}-monthly-budget"
  budget_type  = "COST"
  limit_amount = format("%.2f", var.budget_amount)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator = "GREATER_THAN"
    threshold           = 80
    threshold_type      = "PERCENTAGE"
    notification_type   = "FORECASTED"
    subscriber_email_addresses = var.budget_emails
  }

  notification {
    comparison_operator = "GREATER_THAN"
    threshold           = 100
    threshold_type      = "PERCENTAGE"
    notification_type   = "ACTUAL"
    subscriber_email_addresses = var.budget_emails
  }
}

resource "aws_ce_anomaly_monitor" "account" {
  count        = var.enable_cost_anomaly_detection ? 1 : 0
  name         = "${var.project}-ce-monitor"
  monitor_type = "DIMENSIONAL"
  monitor_dimension = "SERVICE"
}

resource "aws_ce_anomaly_subscription" "alerts" {
  count               = var.enable_cost_anomaly_detection ? 1 : 0
  name                = "${var.project}-ce-subscription"
  frequency           = "DAILY"
  monitor_arn_list    = [aws_ce_anomaly_monitor.account[0].arn]
  threshold_expression = jsonencode({
    And = [ { DimensionValues = { Key = "ANOMALY_TOTAL_IMPACT_ABSOLUTE", MatchOptions=["GREATER_THAN_OR_EQUAL"], Values=["50"] } } ]
  })
  subscriber {
    type    = "EMAIL"
    address = length(var.budget_emails) > 0 ? var.budget_emails[0] : "example@example.com"
  }
}

