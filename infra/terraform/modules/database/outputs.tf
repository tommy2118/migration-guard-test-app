output "endpoint" {
  description = "Database endpoint"
  value       = aws_db_instance.database.endpoint
}

output "port" {
  description = "Database port"
  value       = aws_db_instance.database.port
}

output "database_name" {
  description = "Database name"
  value       = aws_db_instance.database.db_name
}

output "security_group_id" {
  description = "Database security group ID"
  value       = aws_security_group.database.id
}
