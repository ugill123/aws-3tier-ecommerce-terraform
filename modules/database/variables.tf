variable "project" {
  type        = string
  description = "The name of the project, used as a prefix for naming resources."
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, staging, prod), used for naming resources."
}

variable "database_subnet_ids" {
  type        = list(string)
  description = "List of isolated database subnet IDs where the RDS instance will be deployed."
}

variable "db_security_group_id" {
  type        = string
  description = "The ID of the Database Security Group to attach to the RDS instance."
}