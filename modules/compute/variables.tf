variable "project" {
  type        = string
  description = "The name of the project, used as a prefix for naming resources."
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, staging, prod), used for naming resources."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs where EC2 instances will be deployed."
}

variable "app_sg_id" {
  type        = string
  description = "The ID of the Application Security Group."
}

variable "target_group_arn" {
  type        = string
  description = "The ARN of the ALB Target Group to register instances with."
}

variable "app_instance_profile_name" {
  type        = string
  description = "The name of the IAM instance profile for the EC2 instances."
}

variable "db_endpoint" {
  type        = string
  description = "The RDS Database endpoint."
}

variable "db_secret_arn" {
  type        = string
  description = "The ARN of the database credentials in Secrets Manager."
}

variable "redis_endpoint" {
  type        = string
  description = "The ElastiCache Redis endpoint."
}