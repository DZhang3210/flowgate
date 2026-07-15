resource "aws_elasticache_replication_group" "main" {
    replication_group_id = "${var.app_name}-${var.environment}-redis"
    description =  "redis cache"
    node_type = var.node_type
    engine_version = var.redis_version
    security_group_ids = var.security_group_ids
    subnet_group_name = var.subnet_group_name 
    num_cache_clusters = 1
}