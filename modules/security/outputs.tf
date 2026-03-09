output "alb_sg_id" {
  description = "The ID of the Application Load Balancer Security Group."
  value       = aws_security_group.alb_sg.id
}

output "app_sg_id" {
  description = "The ID of the Application Tier (EC2) Security Group."
  value       = aws_security_group.app_sg.id
}

output "db_sg_id" {
  description = "The ID of the Database Tier (RDS) Security Group."
  value       = aws_security_group.db_sg.id
}

output "cache_sg_id" {
  description = "The ID of the Cache Tier (Redis) Security Group."
  value       = aws_security_group.cache_sg.id
}