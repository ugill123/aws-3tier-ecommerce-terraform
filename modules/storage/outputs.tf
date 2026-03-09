output "static_assets_bucket_id" {
  description = "The ID of the static assets bucket."
  value       = aws_s3_bucket.static_assets.id
}

output "static_assets_bucket_regional_domain_name" {
  description = "The regional domain name of the assets bucket (needed by CloudFront)."
  value       = aws_s3_bucket.static_assets.bucket_regional_domain_name
}

output "logs_bucket_id" {
  description = "The ID of the centralized logs bucket (needed by ALB and CloudFront)."
  value       = aws_s3_bucket.logs.id
}

output "logs_bucket_domain_name" {
  description = "The domain name of the logs bucket (needed by CloudFront)."
  value       = aws_s3_bucket.logs.bucket_domain_name
}

output "oai_iam_arn" {
  description = "The IAM ARN of the CloudFront OAI."
  value       = aws_cloudfront_origin_access_identity.oai.iam_arn
}

output "oai_cloudfront_access_identity_path" {
  description = "The CloudFront OAI path."
  value       = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
}