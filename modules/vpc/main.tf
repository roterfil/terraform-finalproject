# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = merge(var.common_tags, { 
    Name = "${var.name_prefix}-VPC" 
  })
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, { 
    Name = "${var.name_prefix}-IGW" 
  })
}

# Public Subnets (AZ1 and AZ2)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, { 
    Name = "${var.name_prefix}-PublicSubnet-${count.index + 1}" 
  })
}

# Private Subnets (AZ1 and AZ2)
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.common_tags, { 
    Name = "${var.name_prefix}-PrivateSubnet-${count.index + 1}" 
  })
}

# NAT Gateway (Specifically in AZ2 Public Subnet)
resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = merge(var.common_tags, { Name = "${var.name_prefix}-NAT-EIP" })
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  # Index [1] ensures it is placed in AZ2 (the second public subnet)
  subnet_id     = aws_subnet.public[1].id 

  tags = merge(var.common_tags, { 
    Name = "${var.name_prefix}-NAT-Gateway" 
  })
  depends_on = [aws_internet_gateway.igw]
}

# 6. Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(var.common_tags, { Name = "${var.name_prefix}-Public-RT" })
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = merge(var.common_tags, { Name = "${var.name_prefix}-Private-RT" })
}

# 7. Route Table Associations (Looped)
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}