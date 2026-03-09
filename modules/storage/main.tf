# 1. Dynamically fetch Account ID and ELB Service Account for the current region
data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "main" {}

locals {
  name_prefix = "${var.project}-${var.environment}"
  account_id  = data.aws_caller_identity.current.account_id
}

# ---------------------------------------------------------------------------
# LOGGING BUCKET SETUP (Unchanged)
# ---------------------------------------------------------------------------

resource "aws_s3_bucket" "logs" {
  bucket        = "${local.name_prefix}-logs-${local.account_id}"
  force_destroy = true 

  tags = {
    Name = "${local.name_prefix}-logs"
  }
}

resource "aws_s3_bucket_ownership_controls" "logs_ownership" {
  bucket = aws_s3_bucket.logs.id 

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "logs_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.logs_ownership]
  
  bucket = aws_s3_bucket.logs.id
  acl    = "log-delivery-write"
}

data "aws_iam_policy_document" "logs_bucket_policy" {
  statement {
    sid       = "AllowALBAccessLogs"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.logs.arn}/alb/AWSLogs/${local.account_id}/*"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }
  }

  statement {
    sid       = "AllowS3ServerAccessLogs"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.logs.arn}/s3-access-logs/*"]
    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }
  }

  statement {
    sid       = "AllowCloudFrontLogs"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.logs.arn}/cloudfront/*"]
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket_policy" "logs_policy" {
  bucket = aws_s3_bucket.logs.id
  policy = data.aws_iam_policy_document.logs_bucket_policy.json
}

# ---------------------------------------------------------------------------
# STATIC ASSETS BUCKET SETUP (UPDATED FOR HTTP HOSTING)
# ---------------------------------------------------------------------------

resource "aws_s3_bucket" "static_assets" {
  bucket        = "${local.name_prefix}-assets-${local.account_id}"
  force_destroy = true 

  tags = {
    Name = "${local.name_prefix}-static-assets"
  }
}

# NEW: Enable Static Website Hosting
resource "aws_s3_bucket_website_configuration" "static_assets_website" {
  bucket = aws_s3_bucket.static_assets.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_logging" "static_assets_logging" {
  bucket        = aws_s3_bucket.static_assets.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "s3-access-logs/"
}

# UPDATED: We must set these to FALSE to allow the public HTTP website to work
resource "aws_s3_bucket_public_access_block" "static_assets_block" {
  bucket = aws_s3_bucket.static_assets.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for ${local.name_prefix} static assets"
}

# UPDATED: Policy now allows CloudFront (Secure) AND Public (Insecure HTTP)
data "aws_iam_policy_document" "static_assets_policy" {
  # Statement for CloudFront OAI
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.static_assets.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }

  # Statement for Public HTTP Website (Fixes Mixed Content issue)
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.static_assets.arn}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "static_assets_policy_attachment" {
  # depends_on ensures the public access block is removed before applying the policy
  depends_on = [aws_s3_bucket_public_access_block.static_assets_block]
  bucket     = aws_s3_bucket.static_assets.id
  policy     = data.aws_iam_policy_document.static_assets_policy.json
}