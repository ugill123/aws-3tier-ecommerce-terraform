locals {
  name_prefix = "${var.project}-${var.environment}"
}

resource "aws_cloudfront_distribution" "this" {
  # 1. Point CloudFront to your Static Assets Bucket
  origin {
    domain_name = var.static_assets_bucket_regional_domain_name
    origin_id   = "S3-${var.static_assets_bucket_id}"

    # Use the OAI VIP pass so users cannot bypass the CDN to hit S3 directly
    s3_origin_config {
      origin_access_identity = var.oai_cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  # 2. Tell CloudFront to write its logs to your centralized Logging Bucket
  logging_config {
    include_cookies = false
    bucket          = var.logs_bucket_domain_name
    prefix          = "cloudfront/" 
  }

  # 3. Standard Caching Rules
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.static_assets_bucket_id}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    # Force HTTPS for security
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Use the most cost-effective tier (North America & Europe)
  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "${local.name_prefix}-cdn"
  }
}