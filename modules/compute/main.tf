# Fetch Latest Amazon Linux 2023 AMI
data "aws_ami" "latest" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# Bastion Host
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.latest.id
  instance_type          = "t2.micro"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.bastion_sg_id]

  key_name = "Borromeo-Act1-Keypair"

  tags = {
    Name = "${var.name_prefix}-BastionHost"
  }
}

# Frontend Launch Template
resource "aws_launch_template" "front" {
  name_prefix   = "front-lt-"
  image_id      = data.aws_ami.latest.id
  instance_type = "t3.micro"
  user_data     = base64encode(var.frontend_userdata)

  key_name = "Borromeo-Act1-Keypair"

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.frontend_sg_id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.name_prefix}-Frontend"
    }
  }
}

# Backend Launch Template
resource "aws_launch_template" "back" {
  name_prefix   = "back-lt-"
  image_id      = data.aws_ami.latest.id
  instance_type = "t3.micro"
  user_data     = base64encode(var.backend_userdata)

  key_name = "Borromeo-Act1-Keypair"

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.backend_sg_id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.name_prefix}-Backend"
    }
  }
}

# Frontend ASG
resource "aws_autoscaling_group" "front" {
  name                = "${var.name_prefix}-Frontend-ASG"
  vpc_zone_identifier = var.vpc_zone_identifier
  target_group_arns   = [var.frontend_tg_arn]
  health_check_type   = "ELB"
  min_size            = 2
  max_size            = 4
  desired_capacity    = 2

  launch_template {
    id      = aws_launch_template.front.id
    version = "$Latest"
  }
}

# Backend ASG
resource "aws_autoscaling_group" "back" {
  name                = "${var.name_prefix}-Backend-ASG"
  vpc_zone_identifier = var.vpc_zone_identifier
  target_group_arns   = [var.backend_tg_arn]
  health_check_type   = "ELB"
  min_size            = 2
  max_size            = 4
  desired_capacity    = 2

  launch_template {
    id      = aws_launch_template.back.id
    version = "$Latest"
  }
}
