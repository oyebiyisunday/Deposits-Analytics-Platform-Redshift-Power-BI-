# PagerDuty API Destination (optional)
resource "aws_cloudwatch_event_connection" "pd_conn" {
  count               = var.enable_pagerduty ? 1 : 0
  name                = "${var.project}-pd-conn"
  authorization_type  = "API_KEY"
  auth_parameters {
    api_key {
      key   = "Authorization"
      value = "Token token=${var.pagerduty_token}"
    }
  }
}

resource "aws_cloudwatch_event_api_destination" "pd_dest" {
  count                             = var.enable_pagerduty ? 1 : 0
  name                              = "${var.project}-pd-dest"
  connection_arn                    = aws_cloudwatch_event_connection.pd_conn[0].arn
  invocation_endpoint               = "https://events.pagerduty.com/v2/enqueue"
  http_method                       = "POST"
  invocation_rate_limit_per_second  = 10
}

resource "aws_cloudwatch_event_rule" "forward_cw_alarms" {
  count = var.enable_pagerduty ? 1 : 0
  name  = "${var.project}-forward-cw-alarms"
  event_pattern = jsonencode({
    "source": ["aws.cloudwatch"],
    "detail-type": ["CloudWatch Alarm State Change"],
    "detail": {"state": {"value": ["ALARM"]}}
  })
}

resource "aws_cloudwatch_event_target" "pd_target" {
  count     = var.enable_pagerduty ? 1 : 0
  rule      = aws_cloudwatch_event_rule.forward_cw_alarms[0].name
  target_id = "pagerduty"
  arn       = aws_cloudwatch_event_api_destination.pd_dest[0].arn
  role_arn  = var.eventbridge_invoke_role_arn
}
