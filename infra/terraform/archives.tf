data "archive_file" "matillion_trigger" {
  type        = "zip"
  source_dir  = "../../lambda/matillion_trigger"
  output_path = "./dist/matillion_trigger.zip"
}

data "archive_file" "retry_handler" {
  type        = "zip"
  source_dir  = "../../lambda/retry_handler"
  output_path = "./dist/retry_handler.zip"
}

data "archive_file" "validate_schema_prod" {
  type        = "zip"
  source_dir  = "../../lambda/validate_schema_prod"
  output_path = "./dist/validate_schema_prod.zip"
}

data "archive_file" "dq_success_notifier" {
  type        = "zip"
  source_dir  = "../../lambda/dq_success_notifier"
  output_path = "./dist/dq_success_notifier.zip"
}

data "archive_file" "dq_metrics_publisher" {
  type        = "zip"
  source_dir  = "../../lambda/dq_metrics_publisher"
  output_path = "./dist/dq_metrics_publisher.zip"
}

data "archive_file" "redshift_maintenance" {
  type        = "zip"
  source_dir  = "../../lambda/redshift_maintenance"
  output_path = "./dist/redshift_maintenance.zip"
}

data "archive_file" "redshift_autoscaler" {
  type        = "zip"
  source_dir  = "../../lambda/redshift_autoscaler"
  output_path = "./dist/redshift_autoscaler.zip"
}

data "archive_file" "redshift_backup_check" {
  type        = "zip"
  source_dir  = "../../lambda/redshift_backup_check"
  output_path = "./dist/redshift_backup_check.zip"
}
