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

# NAT gateway (recommended in prod for private egress)
# NOTE: allocate an Elastic IP and route private subnets via NAT for OS updates/patching
