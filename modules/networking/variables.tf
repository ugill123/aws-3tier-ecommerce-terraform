variable "project" {
  type        = string
  description = "The name of the project, used as a prefix for naming resources."
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, staging, prod), used for naming resources."
}

variable "vpc_cidr" {
  type        = string
  description = "The IPv4 CIDR block for the VPC."
}

variable "azs" {
  type        = list(string)
  description = "A list of Availability Zones to deploy the subnets into for high availability."
}

variable "public_subnets" {
  type        = list(string)
  description = "A list of CIDR blocks for the public subnets (used for ALBs, NAT Gateways, and bastion hosts if needed)."
}

variable "private_subnets" {
  type        = list(string)
  description = "A list of CIDR blocks for the private subnets (used for internal EC2 application servers)."
}

variable "database_subnets" {
  type        = list(string)
  description = "A list of CIDR blocks for the isolated database subnets (used for RDS and ElastiCache, with no internet routing)."
}