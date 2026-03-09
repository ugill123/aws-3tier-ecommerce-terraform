# Cache Module

Provisions the highly available in-memory data store for the application.

## Resources Created
* **ElastiCache Subnet Group:** Maps the isolated database subnets to ElastiCache.
* **Redis Replication Group:** A highly available Redis cluster with one primary node and one replica, with automatic failover enabled.