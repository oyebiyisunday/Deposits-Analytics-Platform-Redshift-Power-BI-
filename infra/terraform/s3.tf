resource "aws_s3_bucket" "raw"     { bucket = "${var.project}-raw-${var.bucket_suffix}" }
resource "aws_s3_bucket" "stage"   { bucket = "${var.project}-stage-${var.bucket_suffix}" }
resource "aws_s3_bucket" "curated" { bucket = "${var.project}-curated-${var.bucket_suffix}" }

resource "aws_s3_bucket_public_access_block" "all" {
  for_each = {
    raw = aws_s3_bucket.raw.id
    stage = aws_s3_bucket.stage.id
    curated = aws_s3_bucket.curated.id
  }
  bucket = each.value
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "enc" {
  for_each = {
    raw = aws_s3_bucket.raw.id
    stage = aws_s3_bucket.stage.id
    curated = aws_s3_bucket.curated.id
  }
  bucket = each.value
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.data.arn
      sse_algorithm      = "aws:kms"
    }
  }
}

# Optional lifecycle policies
resource "aws_s3_bucket_lifecycle_configuration" "raw_lifecycle" {
  bucket = aws_s3_bucket.raw.id
  rule {
    id = "glacier-archive"
    status = "Enabled"
    transition { days = 120 storage_class = "GLACIER" }
  }
}
