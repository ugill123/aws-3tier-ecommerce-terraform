variable "project" {
  type        = string
  description = "The name of the project, used as a prefix for naming resources."
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, staging, prod), used for naming resources."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the Target Group will be created."
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs where the ALB will be deployed."
}

variable "alb_security_group_id" {
  type        = string
  description = "The ID of the ALB Security Group to allow inbound internet traffic."
}

variable "logs_bucket_id" {
  type        = string
  description = "The name of the S3 bucket where ALB access logs will be stored."
}