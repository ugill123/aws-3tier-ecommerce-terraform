# VPC outputs
output "vpc_id" {
  description = "The VPC ID"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "Public Subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private Subnet IDs"
  value       = module.networking.private_subnet_ids
}

output "database_subnet_ids" {
  description = "Database Subnet IDs"
  value       = module.networking.database_subnet_ids
}

# Security Groups Outputs
output "alb_sg_id" {
  description = "ALB Security Group ID"
  value       = module.security.alb_sg_id
}

output "app_sg_id" {
  description = "Application Security Group ID"
  value       = module.security.app_sg_id
}

output "db_sg_id" {
  description = "Database Security Group ID"
  value       = module.security.db_sg_id
}

output "cache_sg_id" {
  description = "Cache Security Group ID"
  value       = module.security.cache_sg_id
}

# IAM Outputs
output "app_instance_profile_name" {
  description = "EC2 IAM Instance Profile Name"
  value       = module.iam.app_instance_profile_name
}

# Database Outputs

output "database_endpoint" {
  description = "The connection endpoint for the MySQL database."
  value       = module.database.db_endpoint
}

output "database_secret_arn" {
  description = "The ARN of the database credentials in Secrets Manager."
  value       = module.database.db_secret_arn
}

# Cache Outputs
output "redis_primary_endpoint" {
  description = "The primary endpoint address for the Redis cache."
  value       = module.cache.redis_primary_endpoint
}

#ALB Outputs
output "alb_dns_name" {
  description = "The public DNS URL of the Application Load Balancer."
  value       = module.alb.alb_dns_name
}

output "target_group_arn" {
  description = "The ARN of the Load Balancer Target Group."
  value       = module.alb.target_group_arn
}

# Storage Outputs
output "static_assets_bucket_name" {
  description = "The globally unique name of the S3 bucket for uploading assets."
  value       = module.storage.static_assets_bucket_id
}

output "logs_bucket_name" {
  description = "The globally unique name of the centralized logs bucket."
  value       = module.storage.logs_bucket_id
}

#CDN Outputs

output "cloudfront_url" {
  description = "The public URL for your global CDN."
  value       = module.cdn.cloudfront_domain_name
}
#Monitoring Outputs
output "dashboard_name" {
  description = "The name of your production CloudWatch Dashboard"
  value       = module.monitoring.cloudwatch_dashboard_name
}