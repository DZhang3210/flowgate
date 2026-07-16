variable "vpc_id" {
  description = "ID of the VPC to create security groups in"
  type        = string
}

variable "app_name" {
    description = "App name"
    type = string
}

variable "environment" {
    description = "Current running environment"
    type = string
}

variable sqs_queue_arn {
    description = "arn for sqs service"
    type = string
}
variable "vpc_flow_logs_arn" {
  description = "vpc flow logs arn"
  type = string
}

variable "rds_arn" {
  description = "rds arn"
  type = string
}

variable "ecs_cluster_name" {
  description = "ecs_cluster_name"
  type = string
}

variable "aws_region"{
  description = "aws region"
  type = string
}