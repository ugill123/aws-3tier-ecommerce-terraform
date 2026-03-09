This module provisions a comprehensive, production-grade monitoring suite using AWS CloudWatch and AWS SNS. It provides real-time logging, alerting, and visual dashboards for the entire infrastructure stack.

## Core Features
1. **VPC Flow Logs:** Captures all IP traffic going to and from network interfaces in the VPC and routes it to a dedicated CloudWatch Log Group.
2. **Automated Alerting (SNS):** Provisions an SNS topic and email subscription to immediately notify administrators of critical infrastructure events.
3. **Critical Resource Alarms:**
    * **Compute:** Alerts if EC2 Auto Scaling Group CPU exceeds 85%.
    * **Load Balancer:** Alerts on high 5xx server errors (10+/min) or high target latency (>2s).
    * **Database:** Alerts if RDS CPU exceeds 80% or if Free Storage drops below 5GB.
    * **Cache:** Alerts if ElastiCache Redis memory usage exceeds 80%.
4. **Single-Pane-of-Glass Dashboard:** Builds a 10-widget CloudWatch Dashboard visualizing real-time health across the ALB, Compute Tier, Database, and Caching layers.

## Inputs

| Name | Type | Description |
|------|------|-------------|
| `project` | `string` | The project name, used for resource tagging. |
| `environment` | `string` | The deployment environment (e.g., `prod`). |
| `vpc_id` | `string` | The ID of the VPC where Flow Logs will be attached. |
| `alert_email` | `string` | The email address that will receive CloudWatch SNS alerts. |
| `alb_arn_suffix` | `string` | The ARN suffix of the Application Load Balancer. |
| `asg_name` | `string` | The name of the EC2 Auto Scaling Group. |
| `rds_db_identifier` | `string` | The identifier of the RDS database instance. |
| `elasticache_cluster_id` | `string` | The ID of the ElastiCache Redis cluster. |

## Outputs

| Name | Description |
|------|-------------|
| `sns_topic_arn` | The ARN of the SNS topic for alerts. |
| `cloudwatch_dashboard_name` | The name of the generated CloudWatch Dashboard. |

## Usage Example

```hcl
module "monitoring" {
  source = "./modules/monitoring"

  project                = "my-project"
  environment            = "prod"
  vpc_id                 = module.networking.vpc_id
  alert_email            = "alerts@mycompany.com"
  alb_arn_suffix         = module.alb.alb_arn_suffix
  asg_name               = module.compute.asg_name
  rds_db_identifier      = module.database.db_instance_identifier
  elasticache_cluster_id = module.cache.cluster_id
}