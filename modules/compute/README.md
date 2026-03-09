# Compute Module

Provisions the elastic application tier for the 3-Tier Architecture.

## Resources Created
* **AMI Data Source:** Automatically fetches the latest Amazon Linux 2023 image.
* **Launch Template:** Defines instance type, IAM profile, Security Groups, and `user_data` bootstrapping.
* **Auto Scaling Group:** Spans the private subnets, registers instances to the ALB Target Group, and enforces High Availability.