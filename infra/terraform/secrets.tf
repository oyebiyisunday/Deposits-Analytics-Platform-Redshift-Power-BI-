resource "aws_secretsmanager_secret" "redshift" { name = "${var.project}/redshift" }
resource "aws_secretsmanager_secret_version" "redshift" {
  secret_id = aws_secretsmanager_secret.redshift.id
  secret_string = jsonencode({ username = var.redshift_username, password = var.redshift_password })
}
