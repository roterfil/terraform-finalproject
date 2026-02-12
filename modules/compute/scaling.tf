# FRONTEND SCALING
# Scale Out Policy: Add 1 instance
resource "aws_autoscaling_policy" "front_out" {
  name                   = "front-scale-out"
  autoscaling_group_name = aws_autoscaling_group.front.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 60
}

# High CPU Alarm: >= 40% for 1 minute
resource "aws_cloudwatch_metric_alarm" "front_high" {
  alarm_name          = "${var.name_prefix}-Front-CPU-High"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "40"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.front.name
  }

  alarm_actions = [aws_autoscaling_policy.front_out.arn]
}

# Scale In Policy: Remove 1 instance
resource "aws_autoscaling_policy" "front_in" {
  name                   = "front-scale-in"
  autoscaling_group_name = aws_autoscaling_group.front.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 60
}

# Low CPU Alarm: <= 10% for 1 minute
resource "aws_cloudwatch_metric_alarm" "front_low" {
  alarm_name          = "${var.name_prefix}-Front-CPU-Low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.front.name
  }

  alarm_actions = [aws_autoscaling_policy.front_in.arn]
}

# BACKEND SCALING

# Scale Out Policy: Add 1 instance
resource "aws_autoscaling_policy" "back_out" {
  name                   = "back-scale-out"
  autoscaling_group_name = aws_autoscaling_group.back.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 60
}

# High CPU Alarm: >= 40% for 1 minute
resource "aws_cloudwatch_metric_alarm" "back_high" {
  alarm_name          = "${var.name_prefix}-Back-CPU-High"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "40"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.back.name
  }

  alarm_actions = [aws_autoscaling_policy.back_out.arn]
}

# Scale In Policy: Remove 1 instance
resource "aws_autoscaling_policy" "back_in" {
  name                   = "back-scale-in"
  autoscaling_group_name = aws_autoscaling_group.back.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 60
}

# Low CPU Alarm: <= 10% for 1 minute
resource "aws_cloudwatch_metric_alarm" "back_low" {
  alarm_name          = "${var.name_prefix}-Back-CPU-Low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.back.name
  }

  alarm_actions = [aws_autoscaling_policy.back_in.arn]
}
