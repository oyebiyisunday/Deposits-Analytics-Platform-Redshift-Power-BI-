# VPC with public + private subnets (private used by Redshift/EC2/Matillion).
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support  = true
  enable_dns_hostnames= true
  tags = { Name = "${var.project}-vpc" }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnets[count.index]
  map_public_ip_on_launch = false
  tags = { Name = "${var.project}-priv-${count.index}" }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnets[count.index]
  map_public_ip_on_launch = true
  tags = { Name = "${var.project}-pub-${count.index}" }
}

resource "aws_internet_gateway" "igw" { vpc_id = aws_vpc.main.id }

# Public route table (route to internet via IGW)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# NAT gateway (recommended in prod for private egress)
resource "aws_eip" "nat" {
  count = var.nat_enabled ? 1 : 0
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  count         = var.nat_enabled ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[var.public_subnet_nat_index].id
  depends_on    = [aws_internet_gateway.igw]
}

# Private route table (egress via NAT)
resource "aws_route_table" "private" {
  count = var.nat_enabled ? 1 : 0
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[0].id
  }
}

resource "aws_route_table_association" "private" {
  count          = var.nat_enabled ? length(aws_subnet.private) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}
