output "db_endpoint" {
  description = "The connection endpoint for the RDS instance."
  value       = aws_db_instance.this.endpoint
}

output "db_secret_arn" {
  description = "The ARN of the Secrets Manager secret holding the database credentials."
  value       = aws_secretsmanager_secret.db_secret.arn
}

output "db_instance_identifier" {
  description = "The identifier of the RDS instance."
  value       = aws_db_instance.this.identifier
}