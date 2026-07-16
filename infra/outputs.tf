output "ecr_api_repository_url" {
    description = "repo url for ecs api"
     value = module.compute.ecr_api_repository_url
}

output "ecr_worker_repository_url" {
    description = "repo url for ecs worker"
    value = module.compute.ecr_worker_repository_url
}

output "alb_dns_name" {
  value = module.compute.alb_dns_name
}

output "wake_lambda_arn" {
  value = module.idle-scheduler.wake_lambda_arn
}

output "api_desired_count" {
  value = module.compute.ecs_api_desired_count
}

output "worker_desired_count" {
  value = module.compute.ecs_worker_desired_count
}

output "github_actions_iam_role_arn" {
  value = module.cicd.github_actions_iam_role_arn
}

