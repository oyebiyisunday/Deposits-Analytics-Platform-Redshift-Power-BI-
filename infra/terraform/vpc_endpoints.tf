resource "aws_security_group" "endpoint" {
  count       = var.enable_vpc_endpoints ? 1 : 0
  name        = "${var.project}-vpc-endpoints-sg"
  description = "SG for VPC Interface Endpoints"
  vpc_id      = aws_vpc.main.id

  # Interface endpoints create ENIs; allow all egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# S3 Gateway Endpoint attaches to route tables (prefer private)
resource "aws_vpc_endpoint" "s3" {
  count             = var.enable_vpc_endpoints ? 1 : 0
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.nat_enabled ? [aws_route_table.private[0].id] : [aws_route_table.public.id]
}

# Secrets Manager Interface Endpoint
resource "aws_vpc_endpoint" "secretsmanager" {
  count                = var.enable_vpc_endpoints ? 1 : 0
  vpc_id               = aws_vpc.main.id
  service_name         = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type    = "Interface"
  subnet_ids           = [for s in aws_subnet.private : s.id]
  security_group_ids   = [aws_security_group.endpoint[0].id]
  private_dns_enabled  = true
}

# CloudWatch Logs Interface Endpoint
resource "aws_vpc_endpoint" "logs" {
  count                = var.enable_vpc_endpoints ? 1 : 0
  vpc_id               = aws_vpc.main.id
  service_name         = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type    = "Interface"
  subnet_ids           = [for s in aws_subnet.private : s.id]
  security_group_ids   = [aws_security_group.endpoint[0].id]
  private_dns_enabled  = true
}

