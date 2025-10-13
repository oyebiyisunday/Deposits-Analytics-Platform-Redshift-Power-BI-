output "raw_bucket"           { value = aws_s3_bucket.raw.bucket }
output "alerts_topic_arn"     { value = aws_sns_topic.alerts.arn }
output "redshift_role_arn"    { value = aws_iam_role.redshift.arn }
output "redshift_endpoint"    { value = aws_redshift_cluster.this.endpoint }
