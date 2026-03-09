variable "project" {
  type        = string
  description = "The name of the project, used as a prefix for naming resources."
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., prod, dev), used for naming resources."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where Flow Logs will be attached."
}

variable "alert_email" {
  type        = string
  description = "The email address that will receive CloudWatch SNS alerts."
}

variable "alb_arn_suffix" {
  type        = string
  description = "The ARN suffix of the Application Load Balancer, required for CloudWatch metric alarms."
}

variable "asg_name" {
  type        = string
  description = "The name of the EC2 Auto Scaling Group, required for CPU utilization alarms."
}

variable "rds_db_identifier" {
  type        = string
  description = "The identifier of the RDS database instance, required for RDS performance metrics."
}

variable "elasticache_cluster_id" {
  type        = string
  description = "The ID of the ElastiCache Redis cluster, required for Redis memory and connection metrics."
}