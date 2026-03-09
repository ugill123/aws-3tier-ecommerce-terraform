# Application Load Balancer Module

Provisions the public-facing entry point for the architecture.

## Resources Created
* **Application Load Balancer:** Internet-facing ALB deployed in the public subnets.
* **Target Group:** Configured with HTTP health checks on `/`.
* **Listener:** Listens on Port 80 and forwards traffic to the Target Group.