# S3 Server Access Logging for data buckets

resource "aws_s3_bucket" "logs" {
  bucket = "${var.project}-logs-${var.bucket_suffix}"
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule { apply_server_side_encryption_by_default { sse_algorithm = "AES256" } }
}

# Allow source buckets to write access logs (AWS logs delivery already uses internal principals)
resource "aws_s3_bucket_logging" "raw" {
  bucket        = aws_s3_bucket.raw.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "raw/"
}

resource "aws_s3_bucket_logging" "stage" {
  bucket        = aws_s3_bucket.stage.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "stage/"
}

resource "aws_s3_bucket_logging" "curated" {
  bucket        = aws_s3_bucket.curated.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "curated/"
}

# Lifecycle for logs bucket
resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    id     = "logs-retention"
    status = "Enabled"
    transition { days = 30 storage_class = "STANDARD_IA" }
    transition { days = 180 storage_class = "GLACIER" }
    expiration { days = 3650 }
  }
}

# Stage/Curated lifecycle policies (hot -> IA -> Glacier)
resource "aws_s3_bucket_lifecycle_configuration" "stage_lifecycle" {
  bucket = aws_s3_bucket.stage.id
  rule {
    id     = "tiering"
    status = "Enabled"
    transition { days = 30 storage_class = "STANDARD_IA" }
    transition { days = 180 storage_class = "GLACIER" }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "curated_lifecycle" {
  bucket = aws_s3_bucket.curated.id
  rule {
    id     = "tiering"
    status = "Enabled"
    transition { days = 30 storage_class = "STANDARD_IA" }
    transition { days = 180 storage_class = "GLACIER" }
  }
}

