output "bastion_sg_id" {
  value = aws_security_group.bastion.id
}

output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "frontend_sg_id" {
  value = aws_security_group.front.id
}

output "backend_sg_id" {
  value = aws_security_group.back.id
}
