# CloudFront CDN Module

This module provisions a global Content Delivery Network (CDN) using AWS CloudFront. It is designed to securely serve static website assets (like images, CSS, and JavaScript) to users worldwide with extremely low latency.

## Architecture & Security
* **S3 Origin Access:** This module uses an Origin Access Identity (OAI) to securely connect to the S3 Static Assets bucket. This ensures users cannot bypass the CDN to access the S3 bucket directly.
* **Centralized Logging:** All CDN access logs are automatically routed to the centralized S3 logging bucket.
* **Forced HTTPS:** Viewer protocol policies are configured to redirect all HTTP traffic to HTTPS for encrypted transit.
* **Cost Optimization:** Utilizes `PriceClass_100` to keep delivery costs low by using edge locations in North America and Europe.

## Inputs

| Name | Type | Description |
|------|------|-------------|
| `project` | `string` | The project name, used for resource tagging. |
| `environment` | `string` | The deployment environment (e.g., `prod`). |
| `static_assets_bucket_id` | `string` | The ID of the S3 bucket holding static assets. |
| `static_assets_bucket_regional_domain_name` | `string` | The regional domain name of the static assets S3 bucket. |
| `logs_bucket_domain_name` | `string` | The domain name of the centralized logs bucket. |
| `oai_cloudfront_access_identity_path` | `string` | The CloudFront OAI path to securely access the S3 bucket. |

## Outputs

| Name | Description |
|------|-------------|
| `cloudfront_domain_name` | The public domain name of the generated CloudFront distribution. |

## Usage Example

```hcl
module "cdn" {
  source = "./modules/cdn"

  project                                   = "my-project"
  environment                               = "prod"
  static_assets_bucket_id                   = module.storage.static_assets_bucket_id
  static_assets_bucket_regional_domain_name = module.storage.static_assets_bucket_regional_domain_name
  logs_bucket_domain_name                   = module.storage.logs_bucket_domain_name
  oai_cloudfront_access_identity_path       = module.storage.oai_cloudfront_access_identity_path
}