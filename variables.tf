variable "aws_region" {
  type        = string
  description = "The AWS region where resources will be deployed."
  default     = "us-east-1" 
}

variable "project" {
  type        = string
  description = "The name of the project, used as a prefix for all resources."
}

variable "managed_by" {
  type        = string
  description = "Identifier for the team, user, or system responsible for managing this resource (e.g., MSP, DevOps, Terraform)."
}

variable "environment" {
  type        = string
  description = "The deployment environment (dev, staging, prod)."
  
  # BEST PRACTICE: Validation to catch typos (e.g., 'pord' instead of 'prod')
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, or prod."
  }
}

# VPC Variables
variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC"
}

variable "azs" {
  type        = list(string)
  description = "List of Availability Zones"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet CIDR blocks"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet CIDR blocks"
}

variable "database_subnets" {
  type        = list(string)
  description = "List of database subnet CIDR blocks"
}
# Monitoring Variables
variable "alert_email" {
  type        = string
  description = "Email address for CloudWatch alerts"
}