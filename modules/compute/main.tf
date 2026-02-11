# AMI Data Source
data "aws_ami" "latest" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-*-x86_64"]
  }
}

# Bastion
resource "aws_instance" "bastion" {
  ami             = data.aws_ami.latest.id
  instance_type   = "t2.micro"
  subnet_id       = var.public_subnet_id
  security_groups = [var.bastion_sg_id]

  tags = {
    Name        = "${var.lastname}-${var.project_name}-BastionHost"
    Engineer    = var.engineer_name
    ProjectCode = var.project_code
  }
}

# Frontend Launch Template
resource "aws_launch_template" "front" {
  name_prefix   = "frontend-lt"
  image_id      = data.aws_ami.latest.id
  instance_type = "t3.micro"
  user_data     = base64encode(var.frontend_userdata)

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.frontend_sg_id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.lastname}-${var.project_name}-Frontend"
      Engineer    = var.engineer_name
      ProjectCode = var.project_code
    }
  }
}

# Backend Launch Template
resource "aws_launch_template" "back" {
  name_prefix   = "backend-lt"
  image_id      = data.aws_ami.latest.id
  instance_type = "t3.micro"
  user_data     = base64encode(var.backend_userdata)

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.backend_sg_id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.lastname}-${var.project_name}-Backend"
      Engineer    = var.engineer_name
      ProjectCode = var.project_code
    }
  }
}

# Frontend ASG
resource "aws_autoscaling_group" "front_asg" {
  name                      = "${var.lastname}-${var.project_name}-frontend-asg"
  vpc_zone_identifier       = var.vpc_zone_identifier
  target_group_arns         = [var.frontend_tg_arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300
  min_size                  = 2
  max_size                  = 4
  desired_capacity          = 2

  launch_template {
    id      = aws_launch_template.front.id
    version = "$Latest"
  }
}

# Backend ASG
resource "aws_autoscaling_group" "back_asg" {
  name                = "${var.lastname}-${var.project_name}-backend-asg"
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