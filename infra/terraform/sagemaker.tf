data "aws_iam_policy_document" "sagemaker_assume" {
  statement { actions=["sts:AssumeRole"] principals { type="Service" identifiers=["sagemaker.amazonaws.com"] } }
}

resource "aws_iam_role" "sagemaker" {
  count              = var.enable_sagemaker_notebook ? 1 : 0
  name               = "${var.project}-sagemaker-exec-role"
  assume_role_policy = data.aws_iam_policy_document.sagemaker_assume.json
}

resource "aws_iam_role_policy" "sagemaker_access" {
  count = var.enable_sagemaker_notebook ? 1 : 0
  role  = aws_iam_role.sagemaker[0].id
  policy = jsonencode({
    Version="2012-10-17",
    Statement=[
      {Effect="Allow", Action=["s3:ListBucket"], Resource=[aws_s3_bucket.curated.arn]},
      {Effect="Allow", Action=["s3:GetObject","s3:PutObject","s3:ListBucket"], Resource=["${aws_s3_bucket.curated.arn}/*", aws_s3_bucket.curated.arn]},
      {Effect="Allow", Action=["kms:Decrypt","kms:Encrypt","kms:GenerateDataKey"], Resource=[aws_kms_key.data.arn]},
      {Effect="Allow", Action=["cloudwatch:PutMetricData"], Resource:"*"},
      {Effect="Allow", Action=["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"], Resource:"*"},
      {Effect="Allow", Action=["ecr:GetAuthorizationToken"], Resource:"*"}
    ]
  })
}

resource "aws_security_group" "sagemaker" {
  count       = var.enable_sagemaker_notebook ? 1 : 0
  name        = "${var.project}-sagemaker-sg"
  description = "SageMaker notebook SG"
  vpc_id      = aws_vpc.main.id
  egress {
    from_port=0
    to_port=0
    protocol="-1"
    cidr_blocks=["0.0.0.0/0"]
  }
}

resource "aws_sagemaker_notebook_instance" "dev" {
  count                 = var.enable_sagemaker_notebook ? 1 : 0
  name                  = "${var.project}-nb-dev"
  role_arn              = aws_iam_role.sagemaker[0].arn
  instance_type         = var.sagemaker_instance_type
  subnet_id             = aws_subnet.private[0].id
  security_groups       = [aws_security_group.sagemaker[0].id]
  direct_internet_access = "Disabled"
  lifecycle_config_name = null
  tags = { Environment = "dev" }
}

