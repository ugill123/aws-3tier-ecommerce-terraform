output "redis_primary_endpoint" {
  description = "The primary endpoint address for the Redis cluster."
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}

output "redis_reader_endpoint" {
  description = "The reader endpoint address for the Redis cluster."
  value       = aws_elasticache_replication_group.this.reader_endpoint_address
}


output "cluster_id" {
  description = "The ID of the ElastiCache Replication Group."
  value       = aws_elasticache_replication_group.this.id
}