# Security Module

Provisions tightly scoped network security groups for the 3-Tier Architecture.

## Architecture Highlights
* **ALB SG:** Allows port 80/443 from `0.0.0.0/0`.
* **App SG:** Allows port 80 *only* from the ALB Security Group.
* **DB SG:** Allows port 3306 (MySQL) *only* from the App Security Group.
* **Cache SG:** Allows port 6379 (Redis) *only* from the App Security Group.