# VPC 
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.lastname}-${var.project_name}-vpc"
    Engineer    = var.engineer_name
    ProjectCode = var.project_code
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.lastname}-${var.project_name}-igw"
    Engineer    = var.engineer_name
    ProjectCode = var.project_code
  }
}

# Public Subnets
resource "aws_subnet" "pub_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = var.az_1
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.lastname}-${var.project_name}-public-subnet-1"
    Engineer    = var.engineer_name
    ProjectCode = var.project_code
  }
}

resource "aws_subnet" "pub_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = var.az_2
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.lastname}-${var.project_name}-public-subnet-2"
    Engineer    = var.engineer_name
    ProjectCode = var.project_code
  }
}

# Private Subnets
resource "aws_subnet" "priv_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = var.az_1

  tags = {
    Name        = "${var.lastname}-${var.project_name}-private-subnet-1"
    Engineer    = var.engineer_name
    ProjectCode = var.project_code
  }
}

resource "aws_subnet" "priv_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = var.az_2

  tags = {
    Name        = "${var.lastname}-${var.project_name}-private-subnet-2"
    Engineer    = var.engineer_name
    ProjectCode = var.project_code
  }
}

# EIP for Nat Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "${var.lastname}-${var.project_name}-nat-eip"
    Engineer    = var.engineer_name
    ProjectCode = var.project_code
  }
}

# Nat Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.pub_2.id

  tags = {
    Name        = "${var.lastname}-${var.project_name}-nat-gw"
    Engineer    = var.engineer_name
    ProjectCode = var.project_code
  }

  depends_on = [aws_internet_gateway.igw]
}

# Route Tables
resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "${var.lastname}-${var.project_name}-public-rt"
    Engineer    = var.engineer_name
    ProjectCode = var.project_code
  }
}

resource "aws_route_table" "priv_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name        = "${var.lastname}-${var.project_name}-private-rt"
    Engineer    = var.engineer_name
    ProjectCode = var.project_code
  }
}

# Route Table Associations
resource "aws_route_table_association" "p1" {
  subnet_id      = aws_subnet.pub_1.id
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_route_table_association" "p2" {
  subnet_id      = aws_subnet.pub_2.id
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_route_table_association" "pr1" {
  subnet_id      = aws_subnet.priv_1.id
  route_table_id = aws_route_table.priv_rt.id
}

resource "aws_route_table_association" "pr2" {
  subnet_id      = aws_subnet.priv_2.id
  route_table_id = aws_route_table.priv_rt.id
}