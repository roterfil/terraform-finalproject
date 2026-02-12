# Frontend Application Load Balancer (Public)
resource "aws_lb" "front" {
  name               = "${var.name_prefix}-Front-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnets

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-Front-ALB"
  })
}

resource "aws_lb_target_group" "front" {
  name     = "${var.name_prefix}-Front-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "front" {
  load_balancer_arn = aws_lb.front.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front.arn
  }
}

# Backend Network Load Balancer (Internal)
resource "aws_lb" "back" {
  name               = "${var.name_prefix}-Back-NLB"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.private_subnets

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-Back-NLB"
  })
}

resource "aws_lb_target_group" "back" {
  name     = "${var.name_prefix}-Back-TG"
  port     = 80
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    protocol = "TCP"
  }
}

resource "aws_lb_listener" "back" {
  load_balancer_arn = aws_lb.back.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.back.arn
  }
}
