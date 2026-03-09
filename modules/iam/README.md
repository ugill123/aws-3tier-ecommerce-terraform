# IAM Module

Provisions Identity and Access Management (IAM) resources for the Application Tier.

## Resources Created
* **IAM Role:** Trust policy configured for EC2.
* **Custom IAM Policy:** Grants explicit `secretsmanager:GetSecretValue` and CloudWatch Logs write access.
* **Managed Policy Attachment:** Adds `AmazonSSMManagedInstanceCore` for secure Session Manager debugging.
* **Instance Profile:** Wrapper for the role to be attached directly to EC2 Launch Templates.