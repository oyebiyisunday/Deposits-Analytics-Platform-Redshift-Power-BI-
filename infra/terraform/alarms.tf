#############################
# CloudWatch Alarms (Core)  #
#############################

variable "enable_alarms" {
  type        = bool
  default     = true
  description = "Enable creation of CloudWatch alarms for pipeline and Redshift health."
}

variable "alarm_email_actions" {
  type        = list(string)
  default     = []
  description = "Optional additional ARNs to notify (e.g., SNS topics). Defaults to project alerts topic."
}

locals {
  alarm_actions = var.enable_alarms ? concat([aws_sns_topic.alerts.arn], var.alarm_email_actions) : []
}

# DQ Failures > 0
resource "aws_cloudwatch_metric_alarm" "dq_failures" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${var.project}-DQFailures>0"
  alarm_description   = "Data Quality failures detected (DQFailures > 0)."
  namespace           = "${var.project}/DQ"
  metric_name         = "DQFailures"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  evaluation_periods  = 1
  period              = 300
  statistic           = "Maximum"
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
}

#############################
# Lambda Error Alarms       #
#############################

locals {
  lambda_targets = [
    aws_lambda_function.validate_schema_prod.function_name,
    aws_lambda_function.dq_success_notifier.function_name,
    aws_lambda_function.dq_metrics_publisher.function_name,
    aws_lambda_function.redshift_maintenance.function_name,
  ]
}

# validate_schema_prod Errors > 0
resource "aws_cloudwatch_metric_alarm" "lambda_errors_validate" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${var.project}-lambda-validate-errors"
  alarm_description   = "Schema validator Lambda reported Errors > 0"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  dimensions          = { FunctionName = aws_lambda_function.validate_schema_prod.function_name }
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  evaluation_periods  = 1
  period              = 300
  statistic           = "Sum"
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
}

# dq_metrics_publisher Errors > 0
resource "aws_cloudwatch_metric_alarm" "lambda_errors_dq_metrics" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${var.project}-lambda-dq-metrics-errors"
  alarm_description   = "DQ metrics publisher Lambda reported Errors > 0"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  dimensions          = { FunctionName = aws_lambda_function.dq_metrics_publisher.function_name }
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  evaluation_periods  = 1
  period              = 300
  statistic           = "Sum"
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
}

# redshift_maintenance Errors > 0
resource "aws_cloudwatch_metric_alarm" "lambda_errors_maint" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${var.project}-lambda-redshift-maint-errors"
  alarm_description   = "Redshift maintenance Lambda reported Errors > 0"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  dimensions          = { FunctionName = aws_lambda_function.redshift_maintenance.function_name }
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  evaluation_periods  = 1
  period              = 300
  statistic           = "Sum"
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
}

#############################
# SLA Metric Alarms         #
#############################

variable "sla_arrival_minutes"   { type = number, default = 30 }
variable "sla_processing_minutes" { type = number, default = 60 }
variable "sla_freshness_minutes"  { type = number, default = 120 }

resource "aws_cloudwatch_metric_alarm" "sla_arrival" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${var.project}-SLA-Arrival"
  alarm_description   = "Data Arrival delay exceeds SLA"
  namespace           = "${var.project}/SLA"
  metric_name         = "DataArrivalDelay"
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.sla_arrival_minutes
  evaluation_periods  = 1
  period              = 300
  statistic           = "Maximum"
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "sla_processing" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${var.project}-SLA-Processing"
  alarm_description   = "Processing duration exceeds SLA"
  namespace           = "${var.project}/SLA"
  metric_name         = "ProcessingDuration"
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.sla_processing_minutes
  evaluation_periods  = 1
  period              = 300
  statistic           = "Maximum"
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "sla_freshness" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${var.project}-SLA-Freshness"
  alarm_description   = "Data freshness exceeds SLA"
  namespace           = "${var.project}/SLA"
  metric_name         = "DataFreshnessAge"
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.sla_freshness_minutes
  evaluation_periods  = 1
  period              = 300
  statistic           = "Maximum"
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
}

#############################
# Redshift Health Alarms    #
#############################

variable "redshift_cpu_threshold" { type = number, default = 90 }
variable "redshift_wlm_queue_threshold" { type = number, default = 5 }

resource "aws_cloudwatch_metric_alarm" "redshift_cpu" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${var.project}-Redshift-CPU"
  alarm_description   = "Redshift CPUUtilization high"
  namespace           = "AWS/Redshift"
  metric_name         = "CPUUtilization"
  dimensions          = { ClusterIdentifier = aws_redshift_cluster.this.cluster_identifier }
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.redshift_cpu_threshold
  evaluation_periods  = 2
  period              = 300
  statistic           = "Average"
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "redshift_wlm_queue" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${var.project}-Redshift-WLMQueue"
  alarm_description   = "Redshift WLM queue length high"
  namespace           = "AWS/Redshift"
  metric_name         = "WLMQueueLength"
  dimensions          = { ClusterIdentifier = aws_redshift_cluster.this.cluster_identifier }
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.redshift_wlm_queue_threshold
  evaluation_periods  = 2
  period              = 300
  statistic           = "Average"
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
}

# Redshift Query Duration (avg) high
variable "redshift_query_duration_ms" { type = number, default = 2000 }
resource "aws_cloudwatch_metric_alarm" "redshift_query_duration" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${var.project}-Redshift-QueryDuration"
  alarm_description   = "Redshift average QueryDuration above threshold"
  namespace           = "AWS/Redshift"
  metric_name         = "QueryDuration"
  dimensions          = { ClusterIdentifier = aws_redshift_cluster.this.cluster_identifier }
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.redshift_query_duration_ms
  evaluation_periods  = 2
  period              = 300
  statistic           = "Average"
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
}

# DB Connections high
variable "redshift_db_connections_threshold" { type = number, default = 200 }
resource "aws_cloudwatch_metric_alarm" "redshift_db_connections" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${var.project}-Redshift-DBConnections"
  alarm_description   = "Redshift DatabaseConnections above threshold"
  namespace           = "AWS/Redshift"
  metric_name         = "DatabaseConnections"
  dimensions          = { ClusterIdentifier = aws_redshift_cluster.this.cluster_identifier }
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.redshift_db_connections_threshold
  evaluation_periods  = 2
  period              = 300
  statistic           = "Average"
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
}

# Backup age alarm
variable "backup_age_hours_threshold" { type = number, default = 26 }
resource "aws_cloudwatch_metric_alarm" "backup_age" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${var.project}-Backup-Age"
  alarm_description   = "Latest Redshift snapshot age exceeds threshold"
  namespace           = "${var.project}/Backup"
  metric_name         = "BackupAgeHours"
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.backup_age_hours_threshold
  evaluation_periods  = 1
  period              = 3600
  statistic           = "Maximum"
  treat_missing_data  = "breaching"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
}
