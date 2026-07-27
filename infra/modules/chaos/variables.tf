variable "app_name" {
  description = "App name"
  type        = string
}

variable "environment" {
  description = "Current running environment"
  type        = string
}

variable "fis_role_arn" {
  description = "IAM role ARN for FIS to assume"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ecs cluster name"
  type        = string
}

variable "ecs_api_service_name" {
  description = "ecs api service name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID, used for subnet-based FIS targets"
  type        = string
}

variable "alb_5xx_alarm_arn" {
  description = "ALB 5xx alarm ARN, used as FIS stop condition for duration-based experiments"
  type        = string
}