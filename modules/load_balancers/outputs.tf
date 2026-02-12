output "frontend_tg_arn" {
  value = aws_lb_target_group.front.arn
}

output "backend_tg_arn" {
  value = aws_lb_target_group.back.arn
}

output "frontend_dns" {
  value = aws_lb.front.dns_name
}

output "backend_dns" {
  value = aws_lb.back.dns_name
}
