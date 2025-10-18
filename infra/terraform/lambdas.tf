resource "aws_lambda_function" "validate_schema_prod" {
  filename         = data.archive_file.validate_schema_prod.output_path
  function_name    = "${var.project}-validate-schema"
  role             = aws_iam_role.lambda.arn
  handler          = "app.lambda_handler"
  runtime          = "python3.9"
  timeout          = 60

  environment {
    variables = {
      ALERTS_TOPIC_ARN = aws_sns_topic.alerts.arn
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic,
  ]
}

resource "aws_lambda_function" "dq_success_notifier" {
  filename         = data.archive_file.dq_success_notifier.output_path
  function_name    = "${var.project}-dq-success-notifier"
  role             = aws_iam_role.lambda.arn
  handler          = "app.lambda_handler"
  runtime          = "python3.9"
  timeout          = 30

  environment {
    variables = {
      WEBHOOK_URL = var.dq_webhook_url != null ? var.dq_webhook_url : ""
      ENV         = "prod"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic,
  ]
}

# S3 notifications to trigger schema validation on new raw files
resource "aws_lambda_permission" "allow_s3_invoke_validate" {
  statement_id  = "AllowS3InvokeValidate"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.validate_schema_prod.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.raw.arn
}

resource "aws_lambda_function" "dq_metrics_publisher" {
  filename         = data.archive_file.dq_metrics_publisher.output_path
  function_name    = "${var.project}-dq-metrics"
  role             = aws_iam_role.lambda.arn
  handler          = "app.lambda_handler"
  runtime          = "python3.9"
  timeout          = 30

  environment {
    variables = {
      METRIC_NAMESPACE = "${var.project}/DQ"
    }
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_basic]
}

resource "aws_s3_bucket_notification" "raw_notifications" {
  bucket = aws_s3_bucket.raw.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.validate_schema_prod.arn
    events              = ["s3:ObjectCreated:Put", "s3:ObjectCreated:CompleteMultipartUpload"]
    filter_prefix       = "sqlserver/"
    filter_suffix       = ".csv"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.validate_schema_prod.arn
    events              = ["s3:ObjectCreated:Put", "s3:ObjectCreated:CompleteMultipartUpload"]
    filter_prefix       = "files/"
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_permission.allow_s3_invoke_validate]
}
