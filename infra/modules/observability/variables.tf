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

variable "alert_email" {
  description = "alert email"
  type = string
}

variable "dlq_name" {
  description = "dlq name"
  type = string
}

variable "ecs_cluster_name" {
  description = "ecs cluster name"
  type = string
}

variable "ecs_api_service_name" {
  description = "ecs api service name"
  type = string
}

variable "alb_arn_suffix" {
  description = "alb arn suffic"
  type = string
}

variable "rds_identifier" {
  description = "rds id"
  type = string
}

variable "cache_cluster_id" {
  description = "cache cluster id"
  type = string
}

variable "sleep_lambda_arn" {
  description = "sleep lambda arn"
  type = string
}
