# Retry Logic and Error Handling Infrastructure
# Dead Letter Queues, Exponential Backoff, and Failure Recovery

# Dead Letter Queue for Failed Lambda Executions
resource "aws_sqs_queue" "lambda_dlq" {
  name                       = "${var.project}-lambda-dlq"
  message_retention_seconds  = 1209600  # 14 days
  visibility_timeout_seconds = 60

  tags = {
    Environment = "prod"
    Purpose     = "Lambda DLQ"
  }
}

# DLQ for Matillion Job Failures
resource "aws_sqs_queue" "matillion_failure_dlq" {
  name                       = "${var.project}-matillion-failure-dlq"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 300

  tags = {
    Environment = "prod"
    Purpose     = "Matillion Job Failure Handling"
  }
}

# Enhanced Lambda with Retry Configuration
resource "aws_lambda_function" "retry_handler" {
  filename      = data.archive_file.retry_handler.output_path
  function_name = "${var.project}-retry-handler"
  role          = aws_iam_role.lambda_retry.arn
  handler       = "app.lambda_handler"
  runtime       = "python3.12"
  timeout       = 900  # 15 minutes
  memory_size   = 512

  # Retry configuration
  dead_letter_config {
    target_arn = aws_sqs_queue.lambda_dlq.arn
  }

  environment {
    variables = {
      MATILLION_BASE_URL = var.matillion_base_url
      SNS_TOPIC_ARN     = aws_sns_topic.alerts.arn
      MAX_RETRIES       = "3"
      RETRY_DELAY_BASE  = "60"  # Base delay in seconds
      DLQ_ARN           = aws_sqs_queue.matillion_failure_dlq.arn
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_retry_logs,
    aws_cloudwatch_log_group.retry_handler,
  ]
}

# CloudWatch Log Group for Retry Handler
resource "aws_cloudwatch_log_group" "retry_handler" {
  name              = "/aws/lambda/${var.project}-retry-handler"
  retention_in_days = 30
}

# IAM Role for Retry Lambda
resource "aws_iam_role" "lambda_retry" {
  name = "${var.project}-lambda-retry-role"

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

resource "aws_iam_role_policy_attachment" "lambda_retry_logs" {
  role       = aws_iam_role.lambda_retry.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_retry_policy" {
  name = "${var.project}-lambda-retry-policy"
  role = aws_iam_role.lambda_retry.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = [
          aws_sqs_queue.lambda_dlq.arn,
          aws_sqs_queue.matillion_failure_dlq.arn
        ]
      },
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
          "lambda:InvokeFunction"
        ]
        Resource = aws_lambda_function.matillion_trigger.arn
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

# EventBridge Rule for Failed Job Retry (every 15 minutes)
resource "aws_cloudwatch_event_rule" "retry_failed_jobs" {
  name                = "${var.project}-retry-failed-jobs"
  description         = "Retry failed ETL jobs every 15 minutes"
  schedule_expression = "cron(0/15 * * * ? *)"  # Every 15 minutes
}

resource "aws_cloudwatch_event_target" "retry_lambda_target" {
  rule      = aws_cloudwatch_event_rule.retry_failed_jobs.name
  target_id = "RetryHandlerTarget"
  arn       = aws_lambda_function.retry_handler.arn
}

# Lambda Permission for Retry EventBridge
resource "aws_lambda_permission" "allow_eventbridge_retry" {
  statement_id  = "AllowExecutionFromEventBridgeRetry"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.retry_handler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.retry_failed_jobs.arn
}
