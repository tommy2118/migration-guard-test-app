output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = aws_lb.app.dns_name
}

output "security_group_id" {
  description = "Security group ID for the application"
  value       = aws_security_group.app.id
}

output "iam_role_name" {
  description = "IAM role name for application instances"
  value       = aws_iam_role.app.name
}
