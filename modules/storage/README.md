# Storage Module

Provisions globally unique S3 buckets for static assets and centralized access logging.

## Resources Created
* **Logs Bucket:** Centralized destination for CloudFront, ALB, and S3 access logs.
* **Assets Bucket:** Highly secure storage for static front-end assets.
* **OAI & Bucket Policies:** Strict IAM policies allowing specific AWS services to read/write as needed.