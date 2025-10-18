provider "aws" {
  alias  = "dr"
  region = var.dr_region != null ? var.dr_region : var.region
}

resource "aws_kms_key" "crr" {
  count               = var.enable_crr && var.dr_region != null ? 1 : 0
  provider            = aws.dr
  description         = "${var.project} CRR KMS"
  enable_key_rotation = true
}

resource "aws_s3_bucket" "raw_dr" {
  count   = var.enable_crr && var.dr_region != null ? 1 : 0
  provider= aws.dr
  bucket  = "${var.project}-raw-${var.bucket_suffix}-dr"
}
resource "aws_s3_bucket" "stage_dr" {
  count   = var.enable_crr && var.dr_region != null ? 1 : 0
  provider= aws.dr
  bucket  = "${var.project}-stage-${var.bucket_suffix}-dr"
}
resource "aws_s3_bucket" "curated_dr" {
  count   = var.enable_crr && var.dr_region != null ? 1 : 0
  provider= aws.dr
  bucket  = "${var.project}-curated-${var.bucket_suffix}-dr"
}

resource "aws_s3_bucket_lifecycle_configuration" "dr_lifecycle" {
  for_each = var.enable_crr && var.dr_region != null ? {
    raw     = aws_s3_bucket.raw_dr[0].id
    stage   = aws_s3_bucket.stage_dr[0].id
    curated = aws_s3_bucket.curated_dr[0].id
  } : {}
  bucket = each.value
  rule { id = "retention" status = "Enabled" expiration { days = var.crr_retention_days } }
}

resource "aws_iam_role" "s3_replication" {
  count = var.enable_crr && var.dr_region != null ? 1 : 0
  name  = "${var.project}-s3-replication-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Effect="Allow", Principal={ Service="s3.amazonaws.com" }, Action="sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy" "s3_replication" {
  count = var.enable_crr && var.dr_region != null ? 1 : 0
  role  = aws_iam_role.s3_replication[0].id
  policy = jsonencode({
    Version="2012-10-17",
    Statement=[
      { Effect="Allow", Action=["s3:GetReplicationConfiguration","s3:ListBucket"], Resource=[aws_s3_bucket.raw.arn, aws_s3_bucket.stage.arn, aws_s3_bucket.curated.arn] },
      { Effect="Allow", Action=["s3:GetObjectVersion","s3:GetObjectVersionAcl","s3:GetObjectVersionForReplication","s3:GetObjectLegalHold","s3:GetObjectVersionTagging","s3:ObjectOwnerOverrideToBucketOwner"], Resource=["${aws_s3_bucket.raw.arn}/*","${aws_s3_bucket.stage.arn}/*","${aws_s3_bucket.curated.arn}/*"] },
      { Effect="Allow", Action=["s3:ReplicateObject","s3:ReplicateDelete","s3:ReplicateTags","s3:ObjectOwnerOverrideToBucketOwner"], Resource=["${aws_s3_bucket.raw_dr[0].arn}/*","${aws_s3_bucket.stage_dr[0].arn}/*","${aws_s3_bucket.curated_dr[0].arn}/*"], Condition={ StringEquals={ "aws:PrincipalOrgID": null } } }
    ]
  })
}

resource "aws_s3_bucket_replication_configuration" "raw_replication" {
  count  = var.enable_crr && var.dr_region != null ? 1 : 0
  bucket = aws_s3_bucket.raw.id
  role   = aws_iam_role.s3_replication[0].arn
  rule {
    id     = "raw-crr"
    status = "Enabled"
    filter { prefix = "" }
    destination { bucket = aws_s3_bucket.raw_dr[0].arn storage_class = "STANDARD" }
  }
}

resource "aws_s3_bucket_replication_configuration" "stage_replication" {
  count  = var.enable_crr && var.dr_region != null ? 1 : 0
  bucket = aws_s3_bucket.stage.id
  role   = aws_iam_role.s3_replication[0].arn
  rule { id = "stage-crr" status = "Enabled" filter { prefix = "" } destination { bucket = aws_s3_bucket.stage_dr[0].arn storage_class = "STANDARD" } }
}

resource "aws_s3_bucket_replication_configuration" "curated_replication" {
  count  = var.enable_crr && var.dr_region != null ? 1 : 0
  bucket = aws_s3_bucket.curated.id
  role   = aws_iam_role.s3_replication[0].arn
  rule { id = "curated-crr" status = "Enabled" filter { prefix = "" } destination { bucket = aws_s3_bucket.curated_dr[0].arn storage_class = "STANDARD" } }
}

