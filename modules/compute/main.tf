# 1. Fetch Latest Amazon Linux 2023 AMI (Joel's Feedback)
data "aws_ami" "latest" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# 2. Bastion Host (t2.micro)
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.latest.id
  instance_type          = "t2.micro"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.bastion_sg_id]

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-BastionHost"
  })
}

# 3. Frontend Launch Template (t3.micro)
resource "aws_launch_template" "front" {
  name_prefix   = "front-lt-"
  image_id      = data.aws_ami.latest.id
  instance_type = "t3.micro"
  user_data     = base64encode(var.frontend_userdata)

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.frontend_sg_id]
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.common_tags, { Name = "${var.name_prefix}-Frontend" })
  }
}

# 4. Backend Launch Template (t3.micro)
resource "aws_launch_template" "back" {
  name_prefix   = "back-lt-"
  image_id      = data.aws_ami.latest.id
  instance_type = "t3.micro"
  user_data     = base64encode(var.backend_userdata)

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.backend_sg_id]
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.common_tags, { Name = "${var.name_prefix}-Backend" })
  }
}

# 5. Frontend ASG (Min 2, Desired 2, Max 4)
resource "aws_autoscaling_group" "front" {
  name                = "${var.name_prefix}-Frontend-ASG"
  vpc_zone_identifier = var.vpc_zone_identifier
  target_group_arns   = [var.frontend_tg_arn]
  health_check_type   = "ELB" # Crucial for LB health replacements
  min_size            = 2
  max_size            = 4
  desired_capacity    = 2

  launch_template {
    id      = aws_launch_template.front.id
    version = "$Latest"
  }
}

# 6. Backend ASG (Min 2, Desired 2, Max 4)
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
