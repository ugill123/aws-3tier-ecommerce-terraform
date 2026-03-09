locals {
  name_prefix = "${var.project}-${var.environment}"
}

# 1. ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "this" {
  name       = "${local.name_prefix}-redis-subnet-group"
  subnet_ids = var.database_subnet_ids
  
  description = "Subnet group for Redis cluster"
}

# 2. Redis Replication Group (Primary + Replica for HA)
resource "aws_elasticache_replication_group" "this" {
  replication_group_id          = "${var.project}-${var.environment}-redis" # Limited to 40 characters
  description                   = "Redis replication group for application session caching"
  node_type                     = "cache.t3.micro" # Cost-effective for assessments
  port                          = 6379
  
  subnet_group_name             = aws_elasticache_subnet_group.this.name
  security_group_ids            = [var.cache_security_group_id]
  
  # High Availability Settings
  automatic_failover_enabled    = true
  num_cache_clusters            = 2
  
  engine                        = "redis"
  engine_version                = "7.1"
  parameter_group_name          = "default.redis7"

  tags = {
    Name = "${local.name_prefix}-redis"
  }
}