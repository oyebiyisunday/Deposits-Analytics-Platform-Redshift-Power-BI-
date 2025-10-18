resource "aws_security_group" "redshift" {
  name        = "${var.project}-redshift-sg"
  description = "Redshift access from allowed CIDRs"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "redshift_ingress" {
  count             = length(var.allowed_cidrs)
  type              = "ingress"
  from_port         = 5439
  to_port           = 5439
  protocol          = "tcp"
  cidr_blocks       = [var.allowed_cidrs[count.index]]
  security_group_id = aws_security_group.redshift.id
  description       = "Redshift access from allowed CIDR"
}

