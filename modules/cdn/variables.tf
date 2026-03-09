variable "project" {
  type        = string
  description = "The name of the project, used as a prefix for naming resources."
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., prod), used for naming resources."
}

variable "static_assets_bucket_id" {
  type        = string
  description = "The ID of the S3 bucket holding static assets."
}

variable "static_assets_bucket_regional_domain_name" {
  type        = string
  description = "The regional domain name of the static assets S3 bucket."
}

variable "logs_bucket_domain_name" {
  type        = string
  description = "The domain name of the centralized logs bucket."
}

variable "oai_cloudfront_access_identity_path" {
  type        = string
  description = "The CloudFront OAI path to securely access the S3 bucket."
}