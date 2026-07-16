variable "app_name" {
    description = "App name"
    type = string
}

variable "environment" {
    description = "Current running environment"
    type = string
}

variable "api_ecr_arn" {
  description = "api ecr arn"
    type = string
}

variable "worker_ecr_arn" {
  description = "worker ecr arn"
    type = string
}

variable "api_ecs_arn" {
  description = "api ecs arn"
    type = string
}

variable "worker_ecs_arn" {
  description = "worker ecs arn"
    type = string
}