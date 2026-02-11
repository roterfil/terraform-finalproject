output "frontend_alb_dns" {
  description = "Application URL"
  value       = "http://${module.load_balancers.frontend_dns}"
}