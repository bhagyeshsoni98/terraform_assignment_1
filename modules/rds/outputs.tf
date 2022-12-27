output "db_password" {
  value       = random_password.db_password.result
  description = "Admin user password of rds instance"
  sensitive   = true
}

output "rds_instance_endpoint" {
  value       = aws_db_instance.mysql_rds_instance.endpoint
  description = "RDS instance endpoint through which db-client can connect to it remotely"
  sensitive   = true
}
