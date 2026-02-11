# Frontend ALB
resource "aws_lb" "front" {
  name               = "${var.lastname}-${var.project_name}-front-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnets

  tags = {
    Name        = "${var.lastname}-${var.project_name}-front-alb"
    Engineer    = var.engineer_name
    ProjectCode = var.project_code
  }
}

resource "aws_lb_target_group" "front" {
  name     = "${var.lastname}-${var.project_name}-front-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path    = "/"
    matcher = "200"
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

# Backend NLB
resource "aws_lb" "back" {
  name               = "${var.lastname}-${var.project_name}-back-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.private_subnets

  tags = {
    Name        = "${var.lastname}-${var.project_name}-back-nlb"
    Engineer    = var.engineer_name
    ProjectCode = var.project_code
  }
}

resource "aws_lb_target_group" "back" {
  name     = "${var.lastname}-${var.project_name}-back-tg"
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