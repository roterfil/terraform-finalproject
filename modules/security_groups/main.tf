# Bastion Security Group (Public SSH)
resource "aws_security_group" "bastion" {
  name        = "${var.name_prefix}-Bastion-SG"
  description = "Allow SSH from anywhere to Bastion"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from Internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "${var.name_prefix}-Bastion-SG" })
}

# ALB Security Group (Public HTTP)
resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-ALB-SG"
  description = "Allow public HTTP traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "${var.name_prefix}-ALB-SG" })
}

# Frontend Security Group (Web Traffic + Bastion SSH)
resource "aws_security_group" "front" {
  name        = "${var.name_prefix}-Frontend-SG"
  description = "Access for Frontend instances"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "SSH from Bastion Host Only"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "${var.name_prefix}-Frontend-SG" })
}

# Backend Security Group (Internal Traffic + Bastion SSH)
resource "aws_security_group" "back" {
  name        = "${var.name_prefix}-Backend-SG"
  description = "Access for Backend instances"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from VPC Internal"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description     = "SSH from Bastion Host Only"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "${var.name_prefix}-Backend-SG" })
}
