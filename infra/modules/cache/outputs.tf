output "redis_port" {
  description = "elasticache port"
  value = aws_elasticache_replication_group.main.port
}

output "redis_address" {
  description = "elasticache address"
  value = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "cache_cluster_id" {
  description = "elasticache cluster id"
  value = tolist(aws_elasticache_replication_group.main.member_clusters)[0]
}