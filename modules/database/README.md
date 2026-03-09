# Database Module

Provisions the highly available relational data tier for the application.

## Resources Created
* **RDS Subnet Group:** Maps the isolated database subnets to RDS.
* **Random Password:** Generates a 16-character secure password.
* **RDS Instance:** Multi-AZ MySQL 8.0 instance.
* **Secrets Manager:** Securely stores the database host, port, username, and generated password as a JSON string.