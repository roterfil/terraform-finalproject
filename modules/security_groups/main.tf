# Bastion Security Group (Public SSH)
resource "aws_security_group" "bastion" {
  name        = "${var.name_prefix}-Bastion-SG"
  description = "Allow SSH from anywhere to Bastion"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-Bastion-SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "bastion_ssh" {
  security_group_id = aws_security_group.bastion.id
  description       = "SSH from Internet"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "bastion_out" {
  security_group_id = aws_security_group.bastion.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ALB Security Group (Public HTTP)
resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-ALB-SG"
  description = "Allow public HTTP traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-ALB-SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTP from Internet"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "alb_out" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Frontend Security Group (Web Traffic + Bastion SSH)
resource "aws_security_group" "front" {
  name        = "${var.name_prefix}-Frontend-SG"
  description = "Access for Frontend instances"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-Frontend-SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "front_http" {
  security_group_id            = aws_security_group.front.id
  description                  = "HTTP from ALB"
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_vpc_security_group_ingress_rule" "front_ssh" {
  security_group_id            = aws_security_group.front.id
  description                  = "SSH from Bastion Host Only"
  referenced_security_group_id = aws_security_group.bastion.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_egress_rule" "front_out" {
  security_group_id = aws_security_group.front.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Backend Security Group (Internal Traffic + Bastion SSH)
resource "aws_security_group" "back" {
  name        = "${var.name_prefix}-Backend-SG"
  description = "Access for Backend instances"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-Backend-SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "back_http" {
  security_group_id = aws_security_group.back.id
  description       = "HTTP from VPC Internal"
  cidr_ipv4         = var.vpc_cidr
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "back_ssh" {
  security_group_id            = aws_security_group.back.id
  description                  = "SSH from Bastion Host Only"
  referenced_security_group_id = aws_security_group.bastion.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_egress_rule" "back_out" {
  security_group_id = aws_security_group.back.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
