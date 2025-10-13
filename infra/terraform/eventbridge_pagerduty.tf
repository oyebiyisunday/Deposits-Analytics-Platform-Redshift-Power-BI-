# PagerDuty API Destination (optional)
resource "aws_cloudwatch_event_connection" "pd_conn" {
  name = "${var.project}-pd-conn"
  authorization_type = "API_KEY"
  auth_parameters { api_key { key="Authorization" value="Token token=<PAGERDUTY_TOKEN>" } }
}

resource "aws_cloudwatch_event_api_destination" "pd_dest" {
  name = "${var.project}-pd-dest"
  connection_arn = aws_cloudwatch_event_connection.pd_conn.arn
  invocation_endpoint = "https://events.pagerduty.com/v2/enqueue"
  http_method = "POST"
  invocation_rate_limit_per_second = 10
}

resource "aws_cloudwatch_event_rule" "forward_cw_alarms" {
  name = "${var.project}-forward-cw-alarms"
  event_pattern = jsonencode({
    "source": ["aws.cloudwatch"],
    "detail-type": ["CloudWatch Alarm State Change"],
    "detail": {"state": {"value": ["ALARM"]}}
  })
}

resource "aws_cloudwatch_event_target" "pd_target" {
  rule = aws_cloudwatch_event_rule.forward_cw_alarms.name
  target_id = "pagerduty"
  arn = aws_cloudwatch_event_api_destination.pd_dest.arn
  role_arn = "arn:aws:iam::<YOUR_AWS_ACCOUNT_ID>:role/<EventBridgeInvokeRole>"
}
