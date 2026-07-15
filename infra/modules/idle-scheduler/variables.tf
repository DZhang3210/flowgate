variable "app_name" {
  description = "app name"
  type = string
  default = "flowgate"
}

variable "environment" {
  description = "app environment"
  type = string
  default = "staging"
}

variable "lambda_role_arn" {
  description = "role arn for lambda"
  type = string
}

variable "ecs_cluster_name" {
  description = "ecs_cluster_name"
  type = string
}

variable "ecs_api_service_name" {
    description = "ecs api service name"
    type = string
}

variable "ecs_worker_service_name" {
    description = "ecs worker service name"
    type = string
}

variable "rds_identifier" {
  description = "rds identifier"
  type = string
}

variable "api_desired_count" {
    description = "number of AZs for ecs api"
    type = number
}

variable "worker_desired_count" {
    description = "number of AZs for ecs worker"
    type = number
}

variable "sns_topic_arn" {
  description = "sns topic arn"
  type = string
}