plugin "aws" {
  enabled = true
  version = "~> 0.30.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

rule "aws_instance_previous_type" { enabled = false }
rule "aws_s3_bucket_logging"      { enabled = true }
rule "aws_s3_bucket_public_acl"   { enabled = true }
rule "aws_cloudwatch_log_group_kms_key_id" { enabled = false }

