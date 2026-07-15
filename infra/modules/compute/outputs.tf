output "alb_dns_name" {
    description = "dns name for alb"
    value = aws_lb.main.dns_name
}

output "alb_arn_suffix" {
  description = "alb arn suffic"
  value = aws_lb.main.arn_suffix
}

output "ecr_api_repository_url" {
    description = "repo url for ecs api"
    value = aws_ecr_repository.api.repository_url
}

output "ecr_worker_repository_url" {
    description = "repo url for ecs worker"
    value = aws_ecr_repository.worker.repository_url
}

output "ecs_cluster_id" {
    description = "cluster id for ecs"
    value = aws_ecs_cluster.main.id
}

output "ecs_cluster_name"{
    description = "cluster name for ecs"
    value = aws_ecs_cluster.main.name
}

output "ecs_api_service_name"{
    description = "ecs api service name"
    value = aws_ecs_service.api.name
}

output "ecs_worker_service_name"{
    description = "ecs worker service name"
    value = aws_ecs_service.worker.name
}

output "ecs_api_desired_count" {
  description = "ecs api desired count"
  value = var.api_desired_count
}

output "ecs_worker_desired_count" {
  description = "ecs worker desired count"
  value = var.worker_desired_count
}