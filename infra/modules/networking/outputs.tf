output "vpc_id" {
    description = "VPC ID"
    value       = aws_vpc.main.id
}

output "public_subnet_ids" {
    description = "Public Subnet Ids"
    value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
    description = "Private Subnet Ids"
    value       = aws_subnet.private[*].id
}

output "database_subnet_ids" {
    description = "Database Subnet Ids"
    value       = aws_subnet.database[*].id
}

output "db_subnet_group_name" {
    description = "Database Subnet Group Name"
    value       = aws_db_subnet_group.main.name
}

output "cache_subnet_group_name" {
    description = "Database Subnet Group Name"
    value       = aws_elasticache_subnet_group.main.name
}

output "vpc_flow_logs_arn" {
    description = "ARN for VPC Flow Logs"
    value = aws_flow_log.vpc.arn
}