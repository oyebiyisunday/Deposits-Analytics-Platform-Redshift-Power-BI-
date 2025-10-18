resource "aws_redshift_subnet_group" "sg" {
  name = "${var.project}-subnets"
  subnet_ids = [for s in aws_subnet.private : s.id]
}

resource "aws_redshift_parameter_group" "pg" {
  name   = "${var.project}-params"
  family = "redshift-1.0"
  parameter { name="enable_user_activity_logging" value="true" }
}

resource "aws_redshift_cluster" "this" {
  cluster_identifier = "${var.project}-ra3"
  node_type          = "ra3.xlplus"
  number_of_nodes    = 2
  master_username    = var.redshift_username
  master_password    = var.redshift_password
  encrypted          = true
  kms_key_id         = aws_kms_key.data.arn
  iam_roles          = [aws_iam_role.redshift.arn]
  cluster_subnet_group_name = aws_redshift_subnet_group.sg.name
  publicly_accessible      = false
  skip_final_snapshot      = false
  vpc_security_group_ids   = length(var.redshift_security_group_ids) > 0 ? var.redshift_security_group_ids : [aws_security_group.redshift.id]
  cluster_parameter_group_name = aws_redshift_parameter_group.pg.name
}
