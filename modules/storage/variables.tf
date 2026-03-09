variable "project" {
  type        = string
  description = "The name of the project, used as a prefix for naming resources."
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, staging, prod), used for naming resources."
}