variable "app_name" {
    description = "App name"
    type = string
    default = "flowgate"
}

variable "environment" {
    description = "Env of application"
    type = string
    default = "staging"
}

variable "aws_region"{
    description = "region of application"
    type = string
    default = "us-east-1"
}

variable "api_cpu"{
    description = "cpu allocated for ecs api"
    type = number
    default = 256
}

variable "api_memory"{
    description = "memory allocated for ecs api"
    type = number
    default = 512
}

variable "worker_cpu"{
    description = "cpu allocated for ecs worker"
    type = number
    default = 256
}

variable "worker_memory"{
    description = "memory allocated for ecs worker"
    type = number
    default = 512
}

variable "execution_role_arn"{
    description = "arn id for execution role"
    type = string
}

variable "api_task_role_arn"{
    description = "arn id for api task role"
    type = string
}

variable "worker_task_role_arn" {
    description = "arn id for worker task role"
    type = string
}

variable "alb_security_group_id" {
    description = "id for alb security group"
    type = string
}

variable "ecs_api_security_group_id" {
    description = "id for ecs api security group"
    type = string
}

variable "ecs_worker_security_group_id" {
    description = "id for ecs worker security group"
    type = string
}

variable "public_subnet_ids" {
    description = "ids for public subnet_ids"
    type = list(string)
}

variable "private_subnet_ids" {
    description = "ids for public subnet_ids"
    type = list(string)
}

variable "vpc_id" {
    description = "vpc id"
    type = string
}

variable "certificate_arn" {
    description = "certificate arn"
    type = string
    default = ""
}

variable "api_desired_count" {
    description = "number of desire ecs api instances"
    type = number
    default = 1
}

variable "worker_desired_count" {
    description = "number of desire ecs worker instances"
    type = number
    default = 1
}

variable "db_host" {
  description = "rds db host address"
  type = string
}

variable "db_port" {
    description = "rds db port"
    type = string
}

variable "redis_host" {
  description = "redis host address"
  type = string
}

variable "redis_port" {
    description = "redis cache port"
    type = string
}

variable "secret_manager_arn" {
    description = "arn per secret manager"
    type = string
}

variable "sqs_queue_url" {
  description = "url for sqs queue"
  type = string
}

variable "sqs_queue_name"{
    description = "name for sqs queue"
    type = string
}