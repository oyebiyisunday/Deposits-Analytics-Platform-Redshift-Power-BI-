resource "aws_sagemaker_feature_group" "accounts" {
  count                 = var.enable_feature_store ? 1 : 0
  feature_group_name    = "${var.project}-fg-accounts"
  record_identifier_name = "account_id"
  event_time_feature_name = "event_time"
  role_arn              = aws_iam_role.sagemaker[0].arn

  feature_definition {
    feature_name = "account_id"
    feature_type = "String"
  }
  feature_definition {
    feature_name = "avg_deposit_30d"
    feature_type = "Fractional"
  }
  feature_definition {
    feature_name = "event_time"
    feature_type = "String"
  }

  online_store_config {
    enable_online_store = true
  }

  offline_store_config {
    s3_storage_config {
      s3_uri = "s3://${aws_s3_bucket.curated.bucket}/feature-store/accounts/"
      kms_key_id = aws_kms_key.data.arn
    }
  }
}

