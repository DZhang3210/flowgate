output "alb_sg_id" {
    description = "id for alb security group"
    value = aws_security_group.alb.id
}

output "ecs_api_sg_id" {
    description = "id for ecs api security group"
    value = aws_security_group.ecs_api.id
}

output "ecs_worker_sg_id" {
    description = "id for ecs worker security group"
    value = aws_security_group.ecs_worker.id
}

output "rds_sg_id" {
    description = "id for rds security group"
    value = aws_security_group.rds.id
}

output "redis_sg_id" {
    description = "id for redis security group"
    value = aws_security_group.redis.id
}

output "ecs_execution_iam_arn" {
    description = "IAM role for ecs_execution"
    value = aws_iam_role.ecs_execution.arn
}

output "ecs_api_iam_arn" {
    description = "IAM role for ecs_api"
    value = aws_iam_role.ecs_api.arn
}

output "ecs_worker_iam_arn" {
    description = "IAM role for ecs_worker"
    value = aws_iam_role.ecs_worker.arn
}

output "vpc_flow_logs_iam_arn" {
    description = "IAM role for vpc flow logs"
    value = aws_iam_role.flow_logs.arn
}

output "idle_scheduler_iam_arn" {
  description = "IAM role for idle_scheduler"
  value = aws_iam_role.idle_scheduler.arn
}

output "aws_sm_arn" {
    description = "aws secret manager arn"
    value = aws_secretsmanager_secret.db_credentials.arn
}

