# EventBridge Scheduling for Automated Pipeline Execution
# Daily job trigger at 00:15 UTC as per runbook requirements

# Lambda function to trigger Matillion jobs via API
resource "aws_lambda_function" "matillion_trigger" {
  filename      = data.archive_file.matillion_trigger.output_path
  function_name = "${var.project}-matillion-trigger"
  role          = aws_iam_role.lambda_scheduler.arn
  handler       = "app.lambda_handler"
  runtime       = "python3.9"
  timeout       = 300

  environment {
    variables = {
      MATILLION_BASE_URL = var.matillion_base_url
      MATILLION_USER     = var.matillion_user
      MATILLION_PASSWORD = var.matillion_password
      SNS_TOPIC_ARN     = aws_sns_topic.alerts.arn
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_scheduler_logs,
    aws_cloudwatch_log_group.matillion_trigger,
  ]
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "matillion_trigger" {
  name              = "/aws/lambda/${var.project}-matillion-trigger"
  retention_in_days = 30
}

# IAM Role for Scheduler Lambda
resource "aws_iam_role" "lambda_scheduler" {
  name = "${var.project}-lambda-scheduler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_scheduler_logs" {
  role       = aws_iam_role.lambda_scheduler.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_scheduler_sns" {
  name = "${var.project}-lambda-scheduler-policy"
  role = aws_iam_role.lambda_scheduler.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.alerts.arn
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:${var.region}:*:secret:${var.project}/*"
      }
    ]
  })
}

# EventBridge Rule for Daily Schedule (00:15 UTC)
resource "aws_cloudwatch_event_rule" "daily_etl_schedule" {
  name                = "${var.project}-daily-etl"
  description         = "Trigger daily ETL pipeline at 00:15 UTC"
  schedule_expression = "cron(15 0 * * ? *)"  # 00:15 UTC daily
}

# EventBridge Target - Matillion Trigger Lambda
resource "aws_cloudwatch_event_target" "matillion_lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_etl_schedule.name
  target_id = "MatillionTriggerTarget"
  arn       = aws_lambda_function.matillion_trigger.arn

  input = jsonencode({
    job_name = "J_ORCH_Load_Deposits"
    environment = "prod"
  })
}

# Lambda Permission for EventBridge
resource "aws_lambda_permission" "allow_eventbridge_matillion" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.matillion_trigger.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_etl_schedule.arn
}
