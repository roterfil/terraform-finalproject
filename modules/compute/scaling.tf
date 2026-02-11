# Frontend Scaling
resource "aws_autoscaling_policy" "front_out" {
  name                   = "frontend-scale-out"
  autoscaling_group_name = aws_autoscaling_group.front_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 60
}

resource "aws_cloudwatch_metric_alarm" "front_high" {
  alarm_name          = "${var.lastname}-${var.project_name}-frontend-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "40"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.front_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.front_out.arn]
}

resource "aws_autoscaling_policy" "front_in" {
  name                   = "frontend-scale-in"
  autoscaling_group_name = aws_autoscaling_group.front_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 60
}

resource "aws_cloudwatch_metric_alarm" "front_low" {
  alarm_name          = "${var.lastname}-${var.project_name}-frontend-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.front_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.front_in.arn]
}

# Backend Scaling
resource "aws_autoscaling_policy" "back_out" {
  name                   = "backend-scale-out"
  autoscaling_group_name = aws_autoscaling_group.back_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 60
}

resource "aws_cloudwatch_metric_alarm" "back_high" {
  alarm_name          = "${var.lastname}-${var.project_name}-backend-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "40"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.back_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.back_out.arn]
}

resource "aws_autoscaling_policy" "back_in" {
  name                   = "backend-scale-in"
  autoscaling_group_name = aws_autoscaling_group.back_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 60
}

resource "aws_cloudwatch_metric_alarm" "back_low" {
  alarm_name          = "${var.lastname}-${var.project_name}-backend-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.back_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.back_in.arn]
}