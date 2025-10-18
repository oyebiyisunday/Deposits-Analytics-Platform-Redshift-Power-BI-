data "aws_caller_identity" "current" {}

resource "aws_glue_catalog_database" "curated" {
  name = var.glue_db_name
}

data "aws_iam_policy_document" "glue_crawler_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals { type = "Service" identifiers = ["glue.amazonaws.com"] }
  }
}

resource "aws_iam_role" "glue_crawler" {
  name               = "${var.project}-glue-crawler-role"
  assume_role_policy = data.aws_iam_policy_document.glue_crawler_assume.json
}

resource "aws_iam_role_policy" "glue_crawler_access" {
  role = aws_iam_role.glue_crawler.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:ListBucket"],
        Resource = [aws_s3_bucket.curated.arn]
      },
      {
        Effect = "Allow",
        Action = ["s3:GetObject", "s3:ListBucket"],
        Resource = ["${aws_s3_bucket.curated.arn}/*", aws_s3_bucket.curated.arn]
      },
      {
        Effect = "Allow",
        Action = ["kms:Decrypt"],
        Resource = [aws_kms_key.data.arn]
      }
    ]
  })
}

resource "aws_glue_crawler" "curated" {
  name          = "${var.project}-curated-crawler"
  role          = aws_iam_role.glue_crawler.arn
  database_name = aws_glue_catalog_database.curated.name
  s3_target { path = "s3://${aws_s3_bucket.curated.bucket}/" }
  recrawl_policy { recrawl_behavior = "CRAWL_EVERYTHING" }
  schema_change_policy { delete_behavior = "LOG" update_behavior = "UPDATE_IN_DATABASE" }
  configuration = jsonencode({ Version = 1.0, Grouping = { TableLevelConfiguration = 3 } })
}

# Lake Formation (optional)
resource "aws_lakeformation_data_lake_settings" "this" {
  count = var.enable_lake_formation ? 1 : 0
  admins = [for a in var.lake_formation_admins : { data_lake_principal_identifier = a }]
}

resource "aws_lakeformation_resource" "curated" {
  count      = var.enable_lake_formation ? 1 : 0
  arn        = aws_s3_bucket.curated.arn
  role_arn   = aws_iam_role.glue_crawler.arn
  depends_on = [aws_lakeformation_data_lake_settings.this]
}

resource "aws_lakeformation_permissions" "db_access" {
  count = var.enable_lake_formation ? 1 : 0
  principal   = aws_iam_role.glue_crawler.arn
  permissions = ["ALL"]
  database {
    name = aws_glue_catalog_database.curated.name
  }
}

