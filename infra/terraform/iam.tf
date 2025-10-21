data "aws_iam_policy_document" "redshift_assume" {
  statement { actions=["sts:AssumeRole"] principals { type="Service" identifiers=["redshift.amazonaws.com"] } }
}
resource "aws_iam_role" "redshift" {
  name = "${var.project}-redshift-role"
  assume_role_policy = data.aws_iam_policy_document.redshift_assume.json
}
resource "aws_iam_role_policy" "redshift_s3" {
  role = aws_iam_role.redshift.id
  policy = jsonencode({
    Version="2012-10-17",
    Statement=[{
      Effect="Allow",
      Action=["s3:GetObject","s3:ListBucket"],
      Resource=[aws_s3_bucket.raw.arn,"${aws_s3_bucket.raw.arn}/*"]
    }]
  })
}

data "aws_iam_policy_document" "lambda_assume" {
  statement { actions=["sts:AssumeRole"] principals { type="Service" identifiers=["lambda.amazonaws.com"] } }
}
resource "aws_iam_role" "lambda" {
  name = "${var.project}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource "aws_iam_role_policy" "lambda_access" {
  role = aws_iam_role.lambda.id
  policy = jsonencode({
    Version="2012-10-17",
    Statement=[
      {Effect="Allow", Action=["s3:GetObject","s3:ListBucket"], Resource:[aws_s3_bucket.raw.arn,"${aws_s3_bucket.raw.arn}/*"]},
      {Effect="Allow", Action:["sns:Publish"], Resource: aws_sns_topic.alerts.arn},
      {Effect="Allow", Action:["cloudwatch:PutMetricData"], Resource:"*"},
      {Effect="Allow", Action:["redshift-data:ExecuteStatement","redshift-data:GetStatementResult"], Resource:"*"},
      {Effect="Allow", Action:["secretsmanager:GetSecretValue"], Resource: aws_secretsmanager_secret.redshift.arn}
    ]
  })
}
